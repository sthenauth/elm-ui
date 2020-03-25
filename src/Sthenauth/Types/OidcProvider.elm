-- This is a generated file.  Do not edit!
module Sthenauth.Types.OidcProvider exposing (..)

import Json.Decode
import Json.Decode.Pipeline
import Json.Encode


type alias OidcProvider =
    { provider_id : String, provider_name : String, logo_url : String }


encoder : OidcProvider -> Json.Encode.Value
encoder a =
    Json.Encode.object [ ("provider_id" , Json.Encode.string a.provider_id)
    , ("provider_name" , Json.Encode.string a.provider_name)
    , ("logo_url" , Json.Encode.string a.logo_url) ]


decoder : Json.Decode.Decoder OidcProvider
decoder =
    Json.Decode.succeed OidcProvider |>
    Json.Decode.Pipeline.required "provider_id" Json.Decode.string |>
    Json.Decode.Pipeline.required "provider_name" Json.Decode.string |>
    Json.Decode.Pipeline.required "logo_url" Json.Decode.string