port module Main exposing (..)

import Css exposing (..)
import Dom.Scroll as Scroll
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
            ( model, Cmd.map LexiconMsg (Lexicon.loadWordDefinition (toString id)) )

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
        [ icon "home" GoHome
        , icon "cog" GoSettings
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
        ]
        [ div
            [ css
                [ headerStyle ]
            ]
            [ headerTitle
            , pageNavigation model.currentPage
            ]
        , activeView
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
            [ text "Welcome the Hindu Lexicon! Type the characters that you know are in a word. All the possible choices will appear. Use less characters if you do not know to the spelling of a word. Use more if want to limit the choices."
            , text " Gurudeva recommended study of one word and associated words. Take:"
            , br [] []
            , div [ css [ textAlign center ] ] [ seeAlso karma "karma" ]
            , br [] []
            , text " and go a word adventure clicking the other that pop up. You can a word to my word, but click the bookmark. When you are in My Word, clicking the bookmark will delete word. "
            ]
        ]


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
                [ searchHeader (Navigate HelpView)
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
                [ h1 [ css [ color theme.palette.white ] ] [ text "You can click on the bookmark icon on word definitions to save them!" ]
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
