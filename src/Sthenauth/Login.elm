module Sthenauth.Login exposing
    ( Login
    , Msg
    , init
    , isLoggedIn
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
import Sthenauth.Internal.Capabilities as Capabilities
import Sthenauth.Internal.Create as Create exposing (Create)
import Sthenauth.Internal.OidcProvider as OidcProvider
import Sthenauth.Internal.View as View
import Sthenauth.Types.AdditionalAuthStep as AdditionalAuthStep exposing (AdditionalAuthStep)
import Sthenauth.Types.Capabilities as Capabilities exposing (Capabilities)
import Sthenauth.Types.Config exposing (Config)
import Sthenauth.Types.Credentials exposing (Credentials)
import Sthenauth.Types.OidcProvider exposing (OidcProvider)
import Sthenauth.Types.PostLogin exposing (PostLogin)
import Sthenauth.Types.ResponseAuthN as ResponseAuthN exposing (ResponseAuthN)


type alias Login =
    { capabilities : Maybe Capabilities
    , config : Config
    , status : LoginStatus
    , credentials : Credentials
    , afterUrl : Maybe String
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
    | UseOidcProvider String
    | SendLogout
    | SwitchToCreate
    | MessageForCreate Create.Msg


{-| Create an initial login controller.

If the end-user is not logged in, you can provide a URL to send the
user to after they have logged in. Otherwise they will be taken to
the default post-login URL.

-}
initialLogin : Config -> Maybe String -> Login
initialLogin cfg url =
    { capabilities = Nothing
    , config = cfg
    , status = NotLoggedIn
    , credentials = { name = "", password = "" }
    , afterUrl = url
    }


init : Config -> Maybe String -> ( Login, Cmd Msg )
init cfg url =
    ( initialLogin cfg url, Capabilities.get cfg LoadCapabilities )


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
            ( { model | status = AttemptingLogin }
            , loginWithCredentials model.config model.credentials
            )

        AuthNResult (Ok res) ->
            responseAuthN res model

        AuthNResult (Err _) ->
            ( { model | status = LoginFailed }
            , Cmd.none
            )

        SetCredentialsName s ->
            let
                cred =
                    model.credentials
            in
            ( { model | credentials = { cred | name = s } }
            , Cmd.none
            )

        SetCredentialsPassword s ->
            let
                cred =
                    model.credentials
            in
            ( { model | credentials = { cred | password = s } }
            , Cmd.none
            )

        UseOidcProvider pid ->
            ( { model | status = AttemptingLogin }
            , OidcProvider.login model.config pid AuthNResult
            )

        SendLogout ->
            ( model, sendLogout model.config )

        SwitchToCreate ->
            ( { model
                | status =
                    Create.init model.config identity
                        |> SwitchedToCreate
              }
            , Cmd.none
            )

        MessageForCreate m ->
            case model.status of
                SwitchedToCreate c ->
                    sendToCreate model m c

                _ ->
                    ( model, Cmd.none )


updateCapabilities : Capabilities -> Login -> Login
updateCapabilities caps model =
    { model
        | capabilities = Just caps
        , status =
            Maybe.withDefault NotLoggedIn
                (Maybe.map (always LoggedIn) caps.existing_session)
    }


responseAuthN : ResponseAuthN -> Login -> ( Login, Cmd Msg )
responseAuthN res model =
    case res of
        ResponseAuthN.LoginFailed ->
            ( { model | status = LoginFailed }
            , Cmd.none
            )

        ResponseAuthN.LoggedIn info ->
            ( { model | status = LoggedIn }
              -- FIXME: This fails because post_login_uri still has
              -- "localhost" set
            , Navigation.pushUrl model.config.urlKey info.post_login_url
            )

        ResponseAuthN.NextStep step ->
            nextStep step model

        ResponseAuthN.LoggedOut ->
            ( { model | status = NotLoggedIn }
            , Cmd.none
            )


nextStep : AdditionalAuthStep -> Login -> ( Login, Cmd Msg )
nextStep step model =
    case step of
        AdditionalAuthStep.RedirectTo url ->
            ( model
            , Navigation.load url
            )


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
            ( { model | status = SwitchedToCreate new }
            , Cmd.map MessageForCreate cmd
            )

        ( Just (Create.Done r), _, _ ) ->
            responseAuthN r model

        ( Just Create.Canceled, _, _ ) ->
            ( { model | status = NotLoggedIn }
            , Cmd.none
            )


{-| Does the end-user currently have an authenticated session?
-}
isLoggedIn : Login -> Bool
isLoggedIn login =
    case login.status of
        LoggedIn ->
            True

        _ ->
            False


authInProgress : Login -> Bool
authInProgress login =
    case login.status of
        AttemptingLogin ->
            True

        _ ->
            False



-- VIEW --


view : Login -> Html Msg
view login =
    case login.status of
        SwitchedToCreate c ->
            Create.view c |> Html.map MessageForCreate

        _ ->
            Html.section [ Attr.class "sthenauth", Attr.class "login" ] <|
                if isLoggedIn login then
                    [ viewLogout login ]

                else
                    List.concat
                        [ viewLoginStatus login.status
                        , viewLoginContainer login
                        ]


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
    case login.capabilities of
        Nothing ->
            [ View.inProgress
            ]

        Just caps ->
            if authInProgress login then
                [ View.inProgress ]

            else
                viewLoginWithCapabilities login caps


viewLoginWithCapabilities : Login -> Capabilities -> List (Html Msg)
viewLoginWithCapabilities login caps =
    if caps.can_login_with_local_account then
        viewOidcForm caps (Html.p [] [ Html.text "Or sign in with your email address:" ])
            ++ [ viewLoginForm login ]

    else
        viewOidcForm caps (Html.text "")


viewOidcForm : Capabilities -> Html Msg -> List (Html Msg)
viewOidcForm caps other =
    if List.isEmpty caps.oidc_providers then
        []

    else
        [ Html.section [ Attr.class "oidc" ]
            (List.map (OidcProvider.view UseOidcProvider) caps.oidc_providers
                ++ [ other ]
            )
        ]


viewLoginForm : Login -> Html Msg
viewLoginForm login =
    let
        canCreate =
            Maybe.withDefault False
                (Maybe.map (\c -> c.can_create_local_account) login.capabilities)

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
                    , Attr.value login.credentials.name
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
                            (String.isEmpty login.credentials.name
                                || String.isEmpty login.credentials.password
                            )
                        ]
                        []
                  ]
                ]
            )
        ]
