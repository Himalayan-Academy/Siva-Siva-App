module Main exposing (..)

import Css exposing (..)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Lexicon exposing (WordList)
import Theme.Colors exposing (..)
import Theme.Elements exposing (..)


---- MODEL ----


type PageId
    = LoadingView
    | SearchView
    | SurpriseView
    | MyWordsView
    | DefinitionView


type alias Model =
    { currentPage : PageId
    , searchInput : Maybe String
    , lexiconModel : Lexicon.Model
    , errorMessage : Maybe String
    }


initialModel : Model
initialModel =
    { currentPage = LoadingView
    , searchInput = Nothing
    , lexiconModel = Lexicon.initialModel
    , errorMessage = Nothing
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, startApplication )



---- UPDATE ----


startApplication : Cmd Msg
startApplication =
    Cmd.map LexiconMsg (Lexicon.loadWordDefinition "367")


type Msg
    = LexiconMsg Lexicon.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LexiconMsg subMsg ->
            let
                ( updateLexiconModel, lexiconCmd ) =
                    Lexicon.update subMsg model.lexiconModel
            in
            ( { model | lexiconModel = updateLexiconModel }, Cmd.map LexiconMsg lexiconCmd )



---- VIEW ----


header : Html Msg
header =
    div
        [ css
            [ textAlign center
            , backgroundColor (hex "#0a4650")
            , height (px 43)
            , displayFlex
            , flexDirection row
            , alignItems center
            , justifyContent center
            ]
        ]
        [ h1
            [ css
                [ fontSize (pt 16)
                , color theme.palette.cream
                , textTransform uppercase
                , margin zero
                ]
            ]
            [ text "A Hindu World of Adventure" ]
        ]


pageNavigation : Html Msg
pageNavigation =
    nav
        [ css
            [ displayFlex
            , flexDirection row
            , backgroundColor theme.palette.darkGreen
            ]
        ]
        [ navButton [] [ text "Search" ]
        , navButton [] [ text "My Words" ]
        , navButton [] [ text "Surprise Me" ]
        ]


appNavigation : Html Msg
appNavigation =
    nav
        [ css
            [ displayFlex
            , flexDirection row
            , justifyContent spaceBetween
            , alignItems center
            , position fixed
            , bottom zero
            , backgroundColor theme.palette.darkBlue
            , height (px 48)
            , width (pct 100)
            , boxShadow4 zero zero (px 5) (rgb 0 0 0)
            ]
        ]
        [ icon "home"
        , icon "cog"
        ]


definitionDisplay : Lexicon.Model -> Html Msg
definitionDisplay model =
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


view : Model -> Html Msg
view model =
    div
        [ css
            [ bodyStyle ]
        ]
        [ div
            [ css
                [ position fixed
                , top zero
                , width (pct 100)
                ]
            ]
            [ header
            , pageNavigation
            ]
        , definitionDisplay model.lexiconModel
        , appNavigation
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view >> toUnstyled
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
