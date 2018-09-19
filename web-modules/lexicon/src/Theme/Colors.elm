module Theme.Colors exposing (ButtonTheme, Palette, Theme, theme)

import Css exposing (..)


type alias Palette =
    { white : Color
    , green : Color
    , lightGreen : Color
    , darkGreen : Color
    , blue : Color
    , darkBlue : Color
    , cream : Color
    , lightBlue : Color
    }


type alias ButtonTheme =
    { background : Color
    , active : Color
    , text : Color
    }


type alias Theme =
    { palette : Palette
    , button : ButtonTheme
    }


theme : Theme
theme =
    { palette =
        { white = rgb 255 255 255
        , green = rgb 122 153 27
        , lightGreen = rgb 171 208 57
        , darkGreen = hex "#03697d"
        , blue = rgb 46 153 174
        , darkBlue = rgb 10 70 80
        , cream = rgb 254 248 222
        , lightBlue = rgb 140 230 250
        }
    , button =
        { background = rgb 77 136 0 --90 158 0
        , active = rgb 57 101 0
        , text = rgb 237 237 237
        }
    }
