module Sthenauth.Create exposing
    ( Create
    , Done(..)
    , Msg
    , init
    , update
    , view
    )

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Attr
import Http
import Sthenauth.Types.Config as Config exposing (Config)
import Sthenauth.Types.Credentials as Credentials exposing (Credentials)
import Sthenauth.Types.ResponseAuthN as ResponseAuthN exposing (ResponseAuthN)
import Sthenauth.View as View


type alias Create a =
    { config : Config
    , name : String
    , password1 : String
    , password2 : String
    , status : Status
    , onResponse : ResponseAuthN -> a
    }


type Error
    = PasswordsDontMatch
    | CreateFailed


type Status
    = Idle
    | Waiting
    | Error Error


type Done a
    = Done a
    | Canceled


type Msg
    = SetName String
    | SetPassword1 String
    | SetPassword2 String
    | SendCreate
    | CreateResult (Result Http.Error ResponseAuthN)
    | Cancel



-- INIT --


init : Config -> (ResponseAuthN -> a) -> Create a
init c f =
    { config = c
    , name = ""
    , password1 = ""
    , password2 = ""
    , status = Idle
    , onResponse = f
    }



-- UPDATE --


update : Msg -> Create a -> ( Maybe (Done a), Create a, Cmd Msg )
update msg model =
    case msg of
        SetName s ->
            ( Nothing
            , { model
                | name = s
                , status = Idle
              }
            , Cmd.none
            )

        SetPassword1 s ->
            ( Nothing
            , { model
                | password1 = s
                , status = checkPasswords model
              }
            , Cmd.none
            )

        SetPassword2 s ->
            ( Nothing
            , { model
                | password2 = s
                , status = checkPasswords model
              }
            , Cmd.none
            )

        SendCreate ->
            case model.status of
                Idle ->
                    ( Nothing
                    , { model | status = Waiting }
                    , sendCreate model
                    )

                _ ->
                    ( Nothing
                    , model
                    , Cmd.none
                    )

        CreateResult (Ok r) ->
            ( Just (Done <| model.onResponse r)
            , { model | status = Idle }
            , Cmd.none
            )

        CreateResult (Err _) ->
            ( Nothing
            , { model | status = Error CreateFailed }
            , Cmd.none
            )

        Cancel ->
            ( Just Canceled, model, Cmd.none )



-- VIEW --


view : Create a -> Html Msg
view model =
    Html.section
        [ Attr.class "sthenauth"
        , Attr.class "create"
        ]
        (List.concat
            [ viewError model
            , viewFormOrStatus model
            ]
        )


viewError : Create a -> List (Html Msg)
viewError model =
    [ Html.div [ Attr.class "error" ] <|
        case model.status of
            Error PasswordsDontMatch ->
                [ Html.text "Passwords don't match." ]

            Error CreateFailed ->
                [ Html.text "Failed" ]

            Idle ->
                []

            Waiting ->
                []
    ]


viewFormOrStatus : Create a -> List (Html Msg)
viewFormOrStatus model =
    if model.status == Waiting then
        [ View.inProgress ]

    else
        [ viewForm model ]


viewForm : Create a -> Html Msg
viewForm model =
    Html.form [ Attr.onSubmit SendCreate ]
        [ Html.fieldset [ Attr.class "inputs" ]
            [ Html.label [ Attr.class "username" ]
                [ Html.span [] [ Html.text "Username:" ]
                , Html.input
                    [ Attr.type_ "text"
                    , Attr.value model.name
                    , Attr.required True
                    , Attr.onInput SetName
                    ]
                    []
                ]
            , Html.label [ Attr.class "password" ]
                [ Html.span [] [ Html.text "Password:" ]
                , Html.input
                    [ Attr.type_ "password"
                    , Attr.value model.password1
                    , Attr.required True
                    , Attr.onInput SetPassword1
                    ]
                    []
                ]
            , Html.label [ Attr.class "password" ]
                [ Html.span [] [ Html.text "Re-enter Password:" ]
                , Html.input
                    [ Attr.type_ "password"
                    , Attr.value model.password2
                    , Attr.required True
                    , Attr.onInput SetPassword2
                    ]
                    []
                ]
            ]
        , Html.fieldset [ Attr.class "buttons" ]
            [ Html.button
                [ Attr.onClick Cancel ]
                [ Html.text "Cancel" ]
            , Html.input
                [ Attr.type_ "submit"
                , Attr.value "Create Account"
                , Attr.disabled (hasError model || hasBlanks model)
                ]
                []
            ]
        ]



-- UTILITIES --


hasError : Create a -> Bool
hasError model =
    case model.status of
        Error _ ->
            True

        _ ->
            False


hasBlanks : Create a -> Bool
hasBlanks model =
    List.any String.isEmpty
        [ model.name
        , model.password1
        , model.password2
        ]


checkPasswords : Create a -> Status
checkPasswords model =
    if
        hasBlanks model
            || model.password1
            == model.password2
    then
        Idle

    else
        Error PasswordsDontMatch


toCredentials : Create a -> Credentials
toCredentials model =
    { name = model.name
    , password = model.password1
    }


sendCreate : Create a -> Cmd Msg
sendCreate model =
    -- FIXME: This needs to capture 400 errors and decode the UserError
    -- that comes from them and then update the error display.
    Http.post
        { url = model.config.baseUrl ++ "/create"
        , body =
            toCredentials model
                |> Credentials.encoder
                |> Http.jsonBody
        , expect = Http.expectJson CreateResult ResponseAuthN.decoder
        }
