module Sthenauth.Internal.View exposing (..)

import Html as Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Attr


inProgress : Html msg
inProgress =
    Html.div [ Attr.class "in-progress" ] []
