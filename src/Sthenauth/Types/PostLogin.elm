-- This is a generated file.  Do not edit!
module Sthenauth.Types.PostLogin exposing (..)

import Json.Decode
import Json.Decode.Pipeline
import Json.Encode


type alias PostLogin =
    { post_login_url : String }


encoder : PostLogin -> Json.Encode.Value
encoder a =
    Json.Encode.object [ ("post_login_url" , Json.Encode.string a.post_login_url) ]


decoder : Json.Decode.Decoder PostLogin
decoder =
    Json.Decode.succeed PostLogin |>
    Json.Decode.Pipeline.required "post_login_url" Json.Decode.string