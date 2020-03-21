-- This is a generated file.  Do not edit!
module Sthenauth.Types.AdditionalAuthStep exposing (..)

import Json.Decode
import Json.Encode


type AdditionalAuthStep
    = RedirectTo String


encoder : AdditionalAuthStep -> Json.Encode.Value
encoder a =
    case a of
        RedirectTo b ->
            Json.Encode.string b


decoder : Json.Decode.Decoder AdditionalAuthStep
decoder =
    Json.Decode.map RedirectTo Json.Decode.string