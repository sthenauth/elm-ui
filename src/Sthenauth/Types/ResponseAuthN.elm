-- This is a generated file.  Do not edit!
module Sthenauth.Types.ResponseAuthN exposing (..)

import Json.Decode
import Json.Decode.Pipeline
import Json.Encode
import Sthenauth.Types.AdditionalAuthStep
import Sthenauth.Types.PostLogin


type ResponseAuthN
    = LoginFailed 
    | LoggedIn Sthenauth.Types.PostLogin.PostLogin
    | NextStep Sthenauth.Types.AdditionalAuthStep.AdditionalAuthStep
    | LoggedOut 


encoder : ResponseAuthN -> Json.Encode.Value
encoder a =
    case a of
        LoginFailed ->
            Json.Encode.object [("tag" , Json.Encode.string "LoginFailed")]
        
        LoggedIn b ->
            Json.Encode.object [ ("tag" , Json.Encode.string "LoggedIn")
            , ("contents" , Sthenauth.Types.PostLogin.encoder b) ]
        
        NextStep b ->
            Json.Encode.object [ ("tag" , Json.Encode.string "NextStep")
            , ("contents" , Sthenauth.Types.AdditionalAuthStep.encoder b) ]
        
        LoggedOut ->
            Json.Encode.object [("tag" , Json.Encode.string "LoggedOut")]


decoder : Json.Decode.Decoder ResponseAuthN
decoder =
    Json.Decode.field "tag" Json.Decode.string |>
    Json.Decode.andThen (\a -> case a of
        "LoginFailed" ->
            Json.Decode.succeed LoginFailed
        
        "LoggedIn" ->
            Json.Decode.succeed LoggedIn |>
            Json.Decode.Pipeline.required "contents" Sthenauth.Types.PostLogin.decoder
        
        "NextStep" ->
            Json.Decode.succeed NextStep |>
            Json.Decode.Pipeline.required "contents" Sthenauth.Types.AdditionalAuthStep.decoder
        
        "LoggedOut" ->
            Json.Decode.succeed LoggedOut
        
        _ ->
            Json.Decode.fail "No matching constructor")