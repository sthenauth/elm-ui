-- This is a generated file.  Do not edit!
module Sthenauth.Types.Authenticator exposing (..)

import Json.Decode
import Json.Encode


type Authenticator
    = MemorizedSecret 
    | LookUpSecret 
    | OutOfBand 
    | SingleFactorOTPSoftware 
    | SingleFactorOTPHardware 
    | MultiFactorOTPSoftware 
    | MultiFactorOTPHardware 
    | SingleFactorCryptoSoftware 
    | MultiFactorCryptoSoftware 
    | SingleFactorCryptoHardware 
    | MultiFactorCryptoHardware 
    | CryptoSoftwareAndPassword 


encoder : Authenticator -> Json.Encode.Value
encoder a =
    case a of
        MemorizedSecret ->
            Json.Encode.string "MemorizedSecret"
        
        LookUpSecret ->
            Json.Encode.string "LookUpSecret"
        
        OutOfBand ->
            Json.Encode.string "OutOfBand"
        
        SingleFactorOTPSoftware ->
            Json.Encode.string "SingleFactorOTPSoftware"
        
        SingleFactorOTPHardware ->
            Json.Encode.string "SingleFactorOTPHardware"
        
        MultiFactorOTPSoftware ->
            Json.Encode.string "MultiFactorOTPSoftware"
        
        MultiFactorOTPHardware ->
            Json.Encode.string "MultiFactorOTPHardware"
        
        SingleFactorCryptoSoftware ->
            Json.Encode.string "SingleFactorCryptoSoftware"
        
        MultiFactorCryptoSoftware ->
            Json.Encode.string "MultiFactorCryptoSoftware"
        
        SingleFactorCryptoHardware ->
            Json.Encode.string "SingleFactorCryptoHardware"
        
        MultiFactorCryptoHardware ->
            Json.Encode.string "MultiFactorCryptoHardware"
        
        CryptoSoftwareAndPassword ->
            Json.Encode.string "CryptoSoftwareAndPassword"


decoder : Json.Decode.Decoder Authenticator
decoder =
    Json.Decode.string |>
    Json.Decode.andThen (\a -> case a of
        "MemorizedSecret" ->
            Json.Decode.succeed MemorizedSecret
        
        "LookUpSecret" ->
            Json.Decode.succeed LookUpSecret
        
        "OutOfBand" ->
            Json.Decode.succeed OutOfBand
        
        "SingleFactorOTPSoftware" ->
            Json.Decode.succeed SingleFactorOTPSoftware
        
        "SingleFactorOTPHardware" ->
            Json.Decode.succeed SingleFactorOTPHardware
        
        "MultiFactorOTPSoftware" ->
            Json.Decode.succeed MultiFactorOTPSoftware
        
        "MultiFactorOTPHardware" ->
            Json.Decode.succeed MultiFactorOTPHardware
        
        "SingleFactorCryptoSoftware" ->
            Json.Decode.succeed SingleFactorCryptoSoftware
        
        "MultiFactorCryptoSoftware" ->
            Json.Decode.succeed MultiFactorCryptoSoftware
        
        "SingleFactorCryptoHardware" ->
            Json.Decode.succeed SingleFactorCryptoHardware
        
        "MultiFactorCryptoHardware" ->
            Json.Decode.succeed MultiFactorCryptoHardware
        
        "CryptoSoftwareAndPassword" ->
            Json.Decode.succeed CryptoSoftwareAndPassword
        
        _ ->
            Json.Decode.fail "No matching constructor")