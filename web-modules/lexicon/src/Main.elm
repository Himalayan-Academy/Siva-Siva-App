module Main exposing (..)

import Css exposing (..)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Html.Styled.Events exposing (onClick)
import Lexicon exposing (Word, WordDefinition, WordList)
import Random
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
    | LoadDefinition String
    | LoadDefinitionByInt Int
    | LoadRandomDefinition


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LexiconMsg subMsg ->
            let
                ( updateLexiconModel, lexiconCmd ) =
                    Lexicon.update subMsg model.lexiconModel
            in
            case subMsg of
                Lexicon.HandleWordDefinitionResponse _ ->
                    ( { model | currentPage = DefinitionView, lexiconModel = updateLexiconModel }, Cmd.map LexiconMsg lexiconCmd )

                _ ->
                    ( { model | lexiconModel = updateLexiconModel }, Cmd.map LexiconMsg lexiconCmd )

        Navigate page ->
            ( { model | currentPage = page }, Cmd.none )

        LoadRandomDefinition ->
            case model.lexiconModel.wordList of
                Just wordList ->
                    let
                        lastItem =
                            List.length wordList - 1

                        gen =
                            Random.int 1 lastItem
                    in
                    ( model, Random.generate LoadDefinitionByInt gen )

                Nothing ->
                    ( model, Cmd.none )

        LoadDefinition id ->
            ( model, Cmd.map LexiconMsg (Lexicon.loadWordDefinition id) )

        LoadDefinitionByInt id ->
            ( model, Cmd.map LexiconMsg (Lexicon.loadWordDefinition (toString id)) )



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
        [ navButton [ onClick (Navigate SearchView) ] [ text "Search" ]
        , navButton [] [ text "My Words" ]
        , navButton [ onClick LoadRandomDefinition ] [ text "Surprise Me" ]
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
                definitionView model.lexiconModel

            LoadingView ->
                loadingView

            SearchView ->
                searchView model.lexiconModel

            _ ->
                h1 [] [ text "not implemented" ]
        , appNavigation
        ]


definitionView : Lexicon.Model -> Html msg
definitionView model =
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


loadingView : Html msg
loadingView =
    h1
        [ css
            [ color theme.palette.white
            , textTransform capitalize
            , marginTop (px 125)
            ]
        ]
        [ text "Loading" ]


addWordItem : Word -> Html Msg
addWordItem word =
    li [ onClick (LoadDefinition word.id) ] [ text word.word ]


searchView : Lexicon.Model -> Html Msg
searchView model =
    case model.wordList of
        Just wordList ->
            div []
                [ ul
                    [ css
                        [ color theme.palette.white
                        , marginTop (px 125)
                        , fontSize (pt 18)
                        , textAlign center
                        , listStyle none
                        , padding (px 20)
                        ]
                    ]
                    (List.map addWordItem wordList)
                , div [ css [ height (px 60) ] ] []
                ]

        Nothing ->
            div []
                [ h1 [] [ text "wait..." ]
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
