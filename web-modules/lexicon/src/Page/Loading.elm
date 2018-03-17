module Page.Loading exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Theme.Colors exposing (..)


view : Html msg
view =
   h1
    [ css
        [ color theme.palette.white
        , textTransform capitalize
        , marginTop (px 125)
        ]
    ]
    [ text "Loading" ]
