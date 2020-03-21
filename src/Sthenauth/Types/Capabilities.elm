-- This is a generated file.  Do not edit!
module Sthenauth.Types.Capabilities exposing (..)

import Dict
import Json.Decode
import Json.Decode.Pipeline
import Json.Encode
import List.Nonempty
import Maybe.Extra
import Sthenauth.Types.Authenticator
import Sthenauth.Types.OidcProvider
import Sthenauth.Types.Session


type alias Capabilities =
    { can_create_local_account : Bool
    , local_primary_authenticators : List Sthenauth.Types.Authenticator.Authenticator
    , local_secondary_authenticators : Dict.Dict String (List.Nonempty.Nonempty Sthenauth.Types.Authenticator.Authenticator)
    , oidc_providers : List Sthenauth.Types.OidcProvider.OidcProvider
    , existing_session : Maybe Sthenauth.Types.Session.Session }


encoder : Capabilities -> Json.Encode.Value
encoder a =
    Json.Encode.object [ ("can_create_local_account" , Json.Encode.bool a.can_create_local_account)
    , ("local_primary_authenticators" , Json.Encode.list Sthenauth.Types.Authenticator.encoder a.local_primary_authenticators)
    , ("local_secondary_authenticators" , Json.Encode.dict identity (\b -> Json.Encode.list Sthenauth.Types.Authenticator.encoder (List.Nonempty.toList b)) a.local_secondary_authenticators)
    , ("oidc_providers" , Json.Encode.list Sthenauth.Types.OidcProvider.encoder a.oidc_providers)
    , ("existing_session" , Maybe.Extra.unwrap Json.Encode.null Sthenauth.Types.Session.encoder a.existing_session) ]


decoder : Json.Decode.Decoder Capabilities
decoder =
    Json.Decode.succeed Capabilities |>
    Json.Decode.Pipeline.required "can_create_local_account" Json.Decode.bool |>
    Json.Decode.Pipeline.required "local_primary_authenticators" (Json.Decode.list Sthenauth.Types.Authenticator.decoder) |>
    Json.Decode.Pipeline.required "local_secondary_authenticators" (Json.Decode.dict (Json.Decode.andThen (\a -> Maybe.Extra.unwrap (Json.Decode.fail "empty list") Json.Decode.succeed (List.Nonempty.fromList a)) (Json.Decode.list Sthenauth.Types.Authenticator.decoder))) |>
    Json.Decode.Pipeline.required "oidc_providers" (Json.Decode.list Sthenauth.Types.OidcProvider.decoder) |>
    Json.Decode.Pipeline.required "existing_session" (Json.Decode.nullable Sthenauth.Types.Session.decoder)