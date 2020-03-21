module Sthenauth.Types.Config exposing (..)

import Browser.Navigation as Navigation


type alias Config =
    { baseUrl : String
    , urlKey : Navigation.Key
    }


default : Navigation.Key -> Config
default key =
    { baseUrl = "/auth"
    , urlKey = key
    }
