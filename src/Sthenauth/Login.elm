module Sthenauth.Login exposing
    ( Login
    , Msg
    , init
    , isLoggedIn
    , status
    , update
    , view
    )

import Browser.Navigation as Navigation
import Dict
import Html as Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Attr
import Http
import Json.Decode
import Sthenauth.Create as Create exposing (Create)
import Sthenauth.Types.AdditionalAuthStep as AdditionalAuthStep exposing (AdditionalAuthStep)
import Sthenauth.Types.Capabilities as Capabilities exposing (Capabilities)
import Sthenauth.Types.Config exposing (Config)
import Sthenauth.Types.Credentials exposing (Credentials)
import Sthenauth.Types.PostLogin exposing (PostLogin)
import Sthenauth.Types.ResponseAuthN as ResponseAuthN exposing (ResponseAuthN)
import Sthenauth.View as View


type alias Login =
    { loginCapabilities : Maybe Capabilities
    , loginConfig : Config
    , loginStatus : LoginStatus
    , loginCredentials : Credentials
    }


type LoginStatus
    = NotLoggedIn
    | AttemptingLogin
    | LoggedIn
    | LoginFailed
    | SwitchedToCreate (Create ResponseAuthN)


type Msg
    = LoadCapabilities (Result Http.Error Capabilities)
    | LoginWithCredentials
    | AuthNResult (Result Http.Error ResponseAuthN)
    | SetCredentialsName String
    | SetCredentialsPassword String
    | SendLogout
    | SwitchToCreate
    | MessageForCreate Create.Msg


initialLogin : Config -> Login
initialLogin cfg =
    { loginCapabilities = Nothing
    , loginConfig = cfg
    , loginStatus = NotLoggedIn
    , loginCredentials = { name = "", password = "" }
    }


status : Login -> LoginStatus
status { loginStatus } =
    loginStatus


init : Config -> ( Login, Cmd Msg )
init cfg =
    ( initialLogin cfg, fetchCapabilities cfg )


update : Msg -> Login -> ( Login, Cmd Msg )
update msg model =
    case msg of
        LoadCapabilities (Ok caps) ->
            ( updateCapabilities caps model
            , Cmd.none
            )

        LoadCapabilities (Err _) ->
            ( model, Cmd.none )

        LoginWithCredentials ->
            ( { model | loginStatus = AttemptingLogin }
            , loginWithCredentials model.loginConfig model.loginCredentials
            )

        AuthNResult (Ok res) ->
            responseAuthN res model

        AuthNResult (Err _) ->
            ( { model | loginStatus = LoginFailed }
            , Cmd.none
            )

        SetCredentialsName s ->
            let
                cred =
                    model.loginCredentials
            in
            ( { model | loginCredentials = { cred | name = s } }
            , Cmd.none
            )

        SetCredentialsPassword s ->
            let
                cred =
                    model.loginCredentials
            in
            ( { model | loginCredentials = { cred | password = s } }
            , Cmd.none
            )

        SendLogout ->
            ( model, sendLogout model.loginConfig )

        SwitchToCreate ->
            ( { model
                | loginStatus =
                    Create.init model.loginConfig identity
                        |> SwitchedToCreate
              }
            , Cmd.none
            )

        MessageForCreate m ->
            case model.loginStatus of
                SwitchedToCreate c ->
                    sendToCreate model m c

                _ ->
                    ( model, Cmd.none )


view : Login -> Html Msg
view login =
    case login.loginStatus of
        SwitchedToCreate c ->
            Create.view c |> Html.map MessageForCreate

        _ ->
            Html.section [ Attr.class "sthenauth", Attr.class "login" ] <|
                if isLoggedIn login then
                    [ viewLogout login ]

                else
                    List.concat
                        [ viewLoginStatus login.loginStatus
                        , viewLoginContainer login
                        ]


updateCapabilities : Capabilities -> Login -> Login
updateCapabilities caps model =
    { model
        | loginCapabilities = Just caps
        , loginStatus =
            Maybe.withDefault NotLoggedIn
                (Maybe.map (always LoggedIn) caps.existing_session)
    }


responseAuthN : ResponseAuthN -> Login -> ( Login, Cmd Msg )
responseAuthN res model =
    case res of
        ResponseAuthN.LoginFailed ->
            ( { model | loginStatus = LoginFailed }
            , Cmd.none
            )

        ResponseAuthN.LoggedIn info ->
            ( { model | loginStatus = LoggedIn }
              -- FIXME: This fails because post_login_uri still has
              -- "localhost" set
            , Navigation.pushUrl model.loginConfig.urlKey info.post_login_uri
            )

        ResponseAuthN.NextStep step ->
            nextStep step model

        ResponseAuthN.LoggedOut ->
            ( { model | loginStatus = NotLoggedIn }
            , Cmd.none
            )


nextStep : AdditionalAuthStep -> Login -> ( Login, Cmd Msg )
nextStep step model =
    case step of
        AdditionalAuthStep.RedirectTo url ->
            ( model
            , Navigation.load url
            )


fetchCapabilities : Config -> Cmd Msg
fetchCapabilities cfg =
    Http.get
        { url = cfg.baseUrl ++ "/capabilities"
        , expect = Http.expectJson LoadCapabilities Capabilities.decoder
        }


loginWithCredentials : Config -> Credentials -> Cmd Msg
loginWithCredentials cfg creds =
    Http.post
        { url = cfg.baseUrl ++ "/login"
        , body = Http.jsonBody (Sthenauth.Types.Credentials.encoder creds)
        , expect = Http.expectJson AuthNResult ResponseAuthN.decoder
        }


sendLogout : Config -> Cmd Msg
sendLogout cfg =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = cfg.baseUrl ++ "/logout"
        , body = Http.emptyBody
        , expect = Http.expectJson AuthNResult ResponseAuthN.decoder
        , timeout = Nothing
        , tracker = Nothing
        }


sendToCreate : Login -> Create.Msg -> Create ResponseAuthN -> ( Login, Cmd Msg )
sendToCreate model msg create =
    case Create.update msg create of
        ( Nothing, new, cmd ) ->
            ( { model | loginStatus = SwitchedToCreate new }
            , Cmd.map MessageForCreate cmd
            )

        ( Just (Create.Done r), _, _ ) ->
            responseAuthN r model

        ( Just Create.Canceled, _, _ ) ->
            ( { model | loginStatus = NotLoggedIn }
            , Cmd.none
            )


isLoggedIn : Login -> Bool
isLoggedIn login =
    case login.loginStatus of
        LoggedIn ->
            True

        _ ->
            False


authInProgress : Login -> Bool
authInProgress login =
    case login.loginStatus of
        AttemptingLogin ->
            True

        _ ->
            False



-- VIEW --


viewLoginStatus : LoginStatus -> List (Html Msg)
viewLoginStatus ls =
    case ls of
        LoginFailed ->
            [ Html.div [ Attr.class "error" ]
                [ Html.text "Login failed: invalid credentials." ]
            ]

        _ ->
            []


viewLogout : Login -> Html Msg
viewLogout login =
    Html.button [ Attr.onClick SendLogout ] [ Html.text "Sign Out" ]


viewLoginContainer : Login -> List (Html Msg)
viewLoginContainer login =
    case login.loginCapabilities of
        Nothing ->
            [ View.inProgress
            ]

        Just _ ->
            List.concat
                [ if authInProgress login then
                    [ View.inProgress ]

                  else
                    [ viewLoginForm login ]
                ]


viewLoginForm : Login -> Html Msg
viewLoginForm login =
    let
        canCreate =
            Maybe.withDefault False
                (Maybe.map (\c -> c.can_create_local_account) login.loginCapabilities)

        createLink =
            if canCreate then
                [ Html.button
                    [ Attr.class "create"
                    , Attr.onClick SwitchToCreate
                    ]
                    [ Html.text "Create Account" ]
                ]

            else
                []
    in
    Html.form [ Attr.onSubmit LoginWithCredentials ]
        [ Html.fieldset [ Attr.class "inputs" ]
            [ Html.label [ Attr.class "username" ]
                [ Html.span [] [ Html.text "Username:" ]
                , Html.input
                    [ Attr.type_ "text"
                    , Attr.value login.loginCredentials.name
                    , Attr.required True
                    , Attr.onInput SetCredentialsName
                    ]
                    []
                ]
            , Html.label [ Attr.class "password" ]
                [ Html.span [] [ Html.text "Password:" ]
                , Html.input
                    [ Attr.type_ "password"
                    , Attr.required True
                    , Attr.onInput SetCredentialsPassword
                    ]
                    []
                ]
            ]
        , Html.fieldset [ Attr.class "buttons" ]
            (List.concat
                [ createLink
                , [ Html.input
                        [ Attr.type_ "submit"
                        , Attr.value "Sign In"
                        , Attr.disabled
                            (String.isEmpty login.loginCredentials.name
                                || String.isEmpty login.loginCredentials.password
                            )
                        ]
                        []
                  ]
                ]
            )
        ]
