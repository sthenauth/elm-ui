module Sthenauth.Internal.OidcProvider exposing (login, view)

import Html as Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Attr
import Http
import Sthenauth.Types.Config exposing (Config)
import Sthenauth.Types.OidcLogin as OidcLogin exposing (OidcLogin)
import Sthenauth.Types.OidcProvider as OidcProvider exposing (OidcProvider)
import Sthenauth.Types.ResponseAuthN as ResponseAuthN exposing (ResponseAuthN)


view : (String -> msg) -> OidcProvider -> Html msg
view msg provider =
    Html.div [ Attr.class "provider" ]
        [ Html.a [ Attr.onClick (msg provider.provider_id) ]
            [ linkBody provider
            ]
        ]


login : Config -> String -> (Result Http.Error ResponseAuthN -> msg) -> Cmd msg
login cfg pid msg =
    Http.post
        { url = cfg.baseUrl ++ "/oidc/login"
        , body = Http.jsonBody (OidcLogin.encoder <| { remote_provider_id = pid })
        , expect = Http.expectJson msg ResponseAuthN.decoder
        }


altText : OidcProvider -> String
altText provider =
    "Sign In with " ++ provider.provider_name


linkBody : OidcProvider -> Html msg
linkBody provider =
    Html.img [ Attr.src provider.logo_url, Attr.alt (altText provider) ] []
