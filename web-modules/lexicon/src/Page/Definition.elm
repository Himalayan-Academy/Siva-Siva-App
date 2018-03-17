module Page.Definition exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Lexicon exposing (WordList)
import Theme.Colors exposing (..)
import Theme.Elements exposing (..)


view : Lexicon.Model -> Html msg
view model =
    case model.currentWord of
        Just word ->
            div []
                [ h1
                    [ css
                        [ color theme.palette.white
                        , textTransform capitalize
                        , marginTop (px 125)
                        ]
                    ]
                    [ text word.word ]
                , div
                    [ css
                        [ displayFlex
                        , flexDirection row
                        , alignItems center
                        , justifyContent center
                        , color theme.palette.green
                        ]
                    ]
                    [ wordDefinitionIcon "bookmark-o"
                    , wordDefinitionIcon "share"
                    ]
                , p
                    [ css
                        [ color theme.palette.white
                        , fontSize (pt 16)
                        , textAlign left
                        , padding (px 20)
                        ]
                    ]
                    [ text word.definition ]
                , div [ css [ height (px 60) ] ] []
                ]

        Nothing ->
            div []
                [ h1 [] [ text "wait..." ]
                ]
