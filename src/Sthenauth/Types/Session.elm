-- This is a generated file.  Do not edit!
module Sthenauth.Types.Session exposing (..)

import Iso8601
import Json.Decode
import Json.Decode.Pipeline
import Json.Encode
import Time


type alias Session =
    { session_expires_at : Time.Posix
    , session_inactive_at : Time.Posix
    , session_created_at : Time.Posix
    , session_updated_at : Time.Posix }


encoder : Session -> Json.Encode.Value
encoder a =
    Json.Encode.object [ ("session_expires_at" , Iso8601.encode a.session_expires_at)
    , ("session_inactive_at" , Iso8601.encode a.session_inactive_at)
    , ("session_created_at" , Iso8601.encode a.session_created_at)
    , ("session_updated_at" , Iso8601.encode a.session_updated_at) ]


decoder : Json.Decode.Decoder Session
decoder =
    Json.Decode.succeed Session |>
    Json.Decode.Pipeline.required "session_expires_at" Iso8601.decoder |>
    Json.Decode.Pipeline.required "session_inactive_at" Iso8601.decoder |>
    Json.Decode.Pipeline.required "session_created_at" Iso8601.decoder |>
    Json.Decode.Pipeline.required "session_updated_at" Iso8601.decoder