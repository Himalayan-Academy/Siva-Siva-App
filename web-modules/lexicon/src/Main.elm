port module Main exposing (..)

import Css exposing (..)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Html.Styled.Events exposing (onClick)
import Json.Encode as JE
import Lexicon exposing (Word, WordDefinition, WordList)
import Random
import Theme.Colors exposing (..)
import Theme.Elements exposing (..)


--- PORTS ---


port saveWord : JE.Value -> Cmd msg


port savedWordListChanged : (WordList -> msg) -> Sub msg


port removeSavedWord : JE.Value -> Cmd msg



--- SUBS ---


subscriptions : Model -> Sub Msg
subscriptions model =
    savedWordListChanged (\wl -> SavedWordListChanged wl)



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
    , savedWords : Maybe WordList
    , query : String
    , errorMessage : Maybe String
    }


initialModel : Model
initialModel =
    { currentPage = SearchView
    , searchInput = Nothing
    , savedWords = Nothing
    , lexiconModel = Lexicon.initialModel
    , query = ""
    , errorMessage = Nothing
    }


init : WordList -> ( Model, Cmd Msg )
init wl =
    if List.isEmpty wl then
        ( initialModel, startApplication )
    else
        ( { initialModel | savedWords = Just wl }, startApplication )



---- UPDATE ----


startApplication : Cmd Msg
startApplication =
    Cmd.map LexiconMsg Lexicon.loadWordList


isWordSaved : String -> WordList -> Bool
isWordSaved word wordList =
    let
        list =
            List.filter (\item -> item.word == word) wordList
    in
    List.isEmpty list


type Msg
    = LexiconMsg Lexicon.Msg
    | Navigate PageId
    | LoadDefinition String
    | LoadDefinitionByInt Int
    | LoadDefinitionByWord String
    | LoadRandomDefinition
    | FilterWordList String
    | SaveWord WordDefinition
    | RemoveSavedWord WordDefinition
    | SavedWordListChanged WordList


filterWordList : String -> WordList -> WordList
filterWordList word list =
    if String.isEmpty word then
        list
    else
        List.filter (\item -> String.contains word item.word) list


isSeeAlsoEmpty : List String -> Bool
isSeeAlsoEmpty list =
    case list of
        f :: r ->
            String.length f == 0

        [] ->
            True


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

        LoadDefinitionByWord word ->
            ( model, Cmd.map LexiconMsg (Lexicon.loadWordDefinitionByWord word model.lexiconModel.wordList) )

        LoadDefinitionByInt id ->
            ( model, Cmd.map LexiconMsg (Lexicon.loadWordDefinition (toString id)) )

        FilterWordList wordOrPart ->
            ( { model | query = wordOrPart }, Cmd.none )

        SaveWord word ->
            ( model, saveWord <| Lexicon.wordEncoder word )

        RemoveSavedWord word ->
            ( model, removeSavedWord <| Lexicon.wordEncoder word )

        SavedWordListChanged swl ->
            ( { model | savedWords = Just swl }, Cmd.none )



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
        , navButton [ onClick LoadRandomDefinition ] [ text "Surprise!" ]
        , navButton [ onClick (Navigate MyWordsView) ] [ text "My Words" ]
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
                definitionView model

            LoadingView ->
                loadingView

            SearchView ->
                searchView model

            MyWordsView ->
                myWordsView model

            _ ->
                h1 [] [ text "not implemented" ]
        , appNavigation
        ]


bookmarkIconView : WordDefinition -> Maybe WordList -> Html Msg
bookmarkIconView definition wordlist =
    let
        list =
            case wordlist of
                Just l ->
                    l

                Nothing ->
                    []

        isSaved =
            isWordSaved definition.word list
    in
    if isSaved then
        wordDefinitionIcon (SaveWord definition) "bookmark-o"
    else
        wordDefinitionIcon (RemoveSavedWord definition) "bookmark"


definitionView : Model -> Html Msg
definitionView model =
    case model.lexiconModel.currentWord of
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
                    [ bookmarkIconView word model.savedWords

                    --, wordDefinitionIcon (SaveWord word) "share"
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
                , if isSeeAlsoEmpty word.seeAlso then
                    div [] []
                  else
                    div []
                        [ takeFurther
                        , div [] (List.map (\i -> seeAlso (LoadDefinitionByWord i) i) word.seeAlso)
                        ]
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


searchView : Model -> Html Msg
searchView model =
    case model.lexiconModel.wordList of
        Just wordList ->
            div
                [ css
                    [ marginTop (px 125) ]
                ]
                [ searchHeader
                , searchBox FilterWordList model.query
                , listHeader
                , ul
                    [ css
                        [ color theme.palette.white
                        , fontSize (pt 18)
                        , textAlign center
                        , listStyle none
                        , padding (px 20)
                        , overflowY scroll
                        , height (px 300)
                        ]
                    ]
                    (List.map addWordItem <| filterWordList model.query wordList)
                ]

        Nothing ->
            div
                [ css
                    [ marginTop (px 125) ]
                ]
                [ h1 [] [ text "Loading ..." ]
                ]


myWordsView : Model -> Html Msg
myWordsView model =
    case model.savedWords of
        Just wordList ->
            div
                [ css
                    [ marginTop (px 125) ]
                ]
                [ searchHeader
                , searchBox FilterWordList model.query
                , listHeader
                , ul
                    [ css
                        [ color theme.palette.white
                        , fontSize (pt 18)
                        , textAlign center
                        , listStyle none
                        , padding (px 20)
                        , overflowY scroll
                        , height (px 300)
                        ]
                    ]
                    (List.map addWordItem <| filterWordList model.query wordList)
                ]

        Nothing ->
            div
                [ css
                    [ marginTop (px 125) ]
                ]
                [ h1 [] [ text "You can click on the bookmark icon on word definitions to save them!" ]
                ]



---- PROGRAM ----


main : Program WordList Model Msg
main =
    Html.programWithFlags
        { view = view >> toUnstyled
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
