-- This is a generated file.  Do not edit!
module Sthenauth.Types.OidcLogin exposing (..)

import Json.Decode
import Json.Decode.Pipeline
import Json.Encode


type alias OidcLogin =
    { remote_provider_id : String }


encoder : OidcLogin -> Json.Encode.Value
encoder a =
    Json.Encode.object [ ("remote_provider_id" , Json.Encode.string a.remote_provider_id) ]


decoder : Json.Decode.Decoder OidcLogin
decoder =
    Json.Decode.succeed OidcLogin |>
    Json.Decode.Pipeline.required "remote_provider_id" Json.Decode.string