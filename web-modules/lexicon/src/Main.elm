module Main exposing (..)

import Css exposing (..)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Lexicon exposing (WordList)
import Page.Definition
import Page.Loading
import Page.Search
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
    { currentPage = SearchView
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
    Cmd.map LexiconMsg Lexicon.loadWordList


type Msg
    = LexiconMsg Lexicon.Msg
    | Navigate PageId


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LexiconMsg subMsg ->
            let
                ( updateLexiconModel, lexiconCmd ) =
                    Lexicon.update subMsg model.lexiconModel
            in
            ( { model | lexiconModel = updateLexiconModel }, Cmd.map LexiconMsg lexiconCmd )

        Navigate page ->
            ( { model | currentPage = page }, Cmd.none )



---- VIEW ----


pageNavigation : PageId -> Html Msg
pageNavigation currentPage =
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


view : Model -> Html Msg
view model =
    div
        [ css
            [ bodyStyle ]
        ]
        [ div
            [ css
                [ headerStyle ]
            ]
            [ headerTitle
            , pageNavigation model.currentPage
            ]
        , case model.currentPage of
            DefinitionView ->
                Page.Definition.view model.lexiconModel

            LoadingView ->
                Page.Loading.view

            SearchView ->
                Page.Search.view model.lexiconModel

            _ ->
                h1 [] [ text "not implemented" ]
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
