port module Main exposing
    ( Model
    , Msg(..)
    , PageId(..)
    , addWordItem
    , appGoHome
    , appGoSettings
    , appNavigation
    , bookmarkIconView
    , definitionView
    , filterWordList
    , helpView
    , init
    , initialModel
    , isSeeAlsoEmpty
    , isWordSaved
    , lcDebug
    , loadingView
    , main
    , myWordsView
    , pageNavigation
    , removeSavedWord
    , saveWord
    , savedWordListChanged
    , scrollTop
    , searchView
    , startApplication
    , subscriptions
    , update
    , view
    )

import Css exposing (..)
-- import Dom.Scroll as Scroll
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, id, src)
import Html.Styled.Events exposing (onClick)
import Json.Encode as JE
import Lexicon exposing (Word, WordDefinition, WordList)
import Random
import Task
import Theme.Colors exposing (..)
import Theme.Elements exposing (..)
import Browser
import Browser.Dom as Dom



--- PORTS ---


port lcDebug : String -> Cmd msg


port saveWord : JE.Value -> Cmd msg


port savedWordListChanged : (WordList -> msg) -> Sub msg


port removeSavedWord : JE.Value -> Cmd msg


port appGoSettings : () -> Cmd msg


port appGoHome : () -> Cmd msg


port scrollTop : () -> Cmd msg



--- SUBS ---


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        d =
            lcDebug "subscription arrived"
    in
    Sub.batch
        [ savedWordListChanged (\wl -> SavedWordListChanged wl)
        , Sub.map LexiconMsg Lexicon.subscriptions
        ]



---- MODEL ----


type PageId
    = LoadingView
    | SearchView
    | SurpriseView
    | MyWordsView
    | DefinitionView
    | HelpView


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
    | GoHome
    | GoSettings
    | NoOp
    | Search


filterWordList : String -> WordList -> WordList
filterWordList word list =
    if String.isEmpty word then
        list

    else
        List.filter (\item -> String.contains (String.toLower word) (String.toLower item.word)) list


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
        GoHome ->
            ( model, appGoHome () )

        GoSettings ->
            ( model, appGoSettings () )

        LexiconMsg subMsg ->
            let
                ( updateLexiconModel, lexiconCmd ) =
                    Lexicon.update subMsg model.lexiconModel
            in
            case subMsg of
                Lexicon.WordListReceived _ ->
                    ( { model | currentPage = SearchView, lexiconModel = updateLexiconModel }, Cmd.map LexiconMsg lexiconCmd )

                Lexicon.WordDefinitionReceived _ ->
                    ( { model | currentPage = DefinitionView, lexiconModel = updateLexiconModel }
                    , Cmd.batch
                        [ Cmd.map LexiconMsg lexiconCmd
                        , scrollTop ()
                        ]
                    )

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
            ( model, Cmd.map LexiconMsg (Lexicon.loadWordDefinition (String.fromInt id)) )

        FilterWordList wordOrPart ->
            ( { model | query = wordOrPart }, Cmd.none )

        SaveWord word ->
            ( model, saveWord <| Lexicon.wordEncoder word )

        RemoveSavedWord word ->
            ( model, removeSavedWord <| Lexicon.wordEncoder word )

        SavedWordListChanged swl ->
            ( { model | savedWords = Just swl }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        Search ->
            ( model, unfocusSearchBox)



---- VIEW ----


pageNavigation : PageId -> Html Msg
pageNavigation currentPage =
    let
        activePage =
            case currentPage of
                SearchView ->
                    "search"

                MyWordsView ->
                    "mywords"

                _ ->
                    "other"
    in
    nav
        [ css
            [ displayFlex
            , flexDirection row
            , backgroundColor theme.palette.darkGreen
            ]
        ]
        [ navButton (activePage == "search") [ onClick (Navigate SearchView) ] [ text "Search" ]
        , navButton False [ onClick LoadRandomDefinition ] [ text "Surprise!" ]
        , navButton (activePage == "mywords") [ onClick (Navigate MyWordsView) ] [ text "My Words" ]
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
        [ icon "chevron-left" GoHome
        , icon "book" GoSettings
        ]


view : Model -> Html Msg
view model =
    let
        activeView =
            case model.currentPage of
                DefinitionView ->
                    definitionView model

                LoadingView ->
                    loadingView

                SearchView ->
                    searchView model

                MyWordsView ->
                    myWordsView model

                HelpView ->
                    helpView (LoadDefinitionByWord "karma")

                _ ->
                    h1 [] [ text "not implemented" ]
    in
    div
        [ css
            [ bodyStyle ]
        , id "body"
        ]
        [ div
            [ css
                [ headerStyle ]
            ]
            [ headerTitle
            , pageNavigation model.currentPage
            ]
            , div [css [flex2 (int 1) (int 1)]] [activeView]
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
            div
                []
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


helpView : msg -> Html msg
helpView karma =
    div []
        [ h1
            [ css
                [ color theme.palette.white
                , textTransform capitalize
                , marginTop (px 125)
                ]
            ]
            [ text "Help" ]
        , p
            [ css
                [ color theme.palette.white
                , textAlign justify
                , fontSize (px 20)
                , padding (px 15)
                ]
            ]
            [ text "Welcome the Hindu Lexicon! Type any contiguous characters that you know are in a word. All the possible choices will appear. Use fewer characters if you do not know exactly how to spell the word. Use more if want to limit the choices. Gurudeva recommended studying a word by exploring its associated words. For example, take the word:"
            , br [] []
            , div [ css [ textAlign center ] ] [ seeAlso karma "karma" ]
            , br [] []
            , text "and go on a word adventure by clicking other words that pop up."
            , br [] []
            , text "You can permanently add word to My Words by clicking on the small bookmark. When you are in My Word, clicking the bookmark will delete that word from your saved list. To see all the words in the My Words list, you must empty the search field."
            ]
        ]


addWordItem : Word -> Html Msg
addWordItem word =
    li [ onClick (LoadDefinition word.id) ] [ text word.word ]



unfocusSearchBox : Cmd Msg
unfocusSearchBox =
  Task.attempt (\_ -> NoOp) (Dom.blur "search-box")

searchView : Model -> Html Msg
searchView model =
    case model.lexiconModel.wordList of
        Just wordList ->
            div
                [ css
                    [ marginTop (px 125) ]
                ]
                [ searchHeader (Navigate HelpView)
                , searchBox FilterWordList Search model.query
                , listHeader
                , ul
                    [ css
                        [ color theme.palette.white
                        , fontSize (pt 18)
                        , textAlign center
                        , listStyle none
                        , padding (px 20)
                        , overflowY scroll
                        , height (px 250)
                        ]
                    ]
                    (List.map addWordItem <| filterWordList model.query wordList)
                ]

        Nothing ->
            div
                [ css
                    [ marginTop (px 125) ]
                ]
                [ h1 [ css [ color theme.palette.white ] ] [ text "Loading ..." ]
                ]


myWordsView : Model -> Html Msg
myWordsView model =
    case model.savedWords of
        Just wordList ->
            div
                [ css
                    [ marginTop (px 125) ]
                ]
                [ searchHeader (Navigate HelpView)
                , searchBox FilterWordList Search  model.query
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
                [ h1 [ css [ color theme.palette.white ] ] [ text "You can click on the bookmark icon on word definitions to save them!" ]
                ]



---- PROGRAM ----


main : Program WordList Model Msg
main =
    Browser.element
        { view = view >> toUnstyled
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
