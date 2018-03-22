module Theme.Colors exposing (..)

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
        { background = rgb 148 192 15
        , active = rgb 101 130 9
        , text = rgb 237 237 237
        }
    }
