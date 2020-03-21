-- This is a generated file.  Do not edit!
module Sthenauth.Types.Credentials exposing (..)

import Json.Decode
import Json.Decode.Pipeline
import Json.Encode


type alias Credentials =
    { name : String, password : String }


encoder : Credentials -> Json.Encode.Value
encoder a =
    Json.Encode.object [ ("name" , Json.Encode.string a.name)
    , ("password" , Json.Encode.string a.password) ]


decoder : Json.Decode.Decoder Credentials
decoder =
    Json.Decode.succeed Credentials |>
    Json.Decode.Pipeline.required "name" Json.Decode.string |>
    Json.Decode.Pipeline.required "password" Json.Decode.string