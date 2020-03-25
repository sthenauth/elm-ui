module Sthenauth.Internal.Capabilities exposing (..)

import Http
import Sthenauth.Types.Capabilities as Capabilities exposing (Capabilities)
import Sthenauth.Types.Config exposing (Config)


{-| Fetch the server capabilities.
-}
get : Config -> (Result Http.Error Capabilities -> msg) -> Cmd msg
get cfg msg =
    Http.get
        { url = cfg.baseUrl ++ "/capabilities"
        , expect = Http.expectJson msg Capabilities.decoder
        }
