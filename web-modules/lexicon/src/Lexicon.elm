port module Lexicon exposing (Model, Msg(..), Word, WordDefinition, WordList, getWordDefinition, getWordList, initialModel, loadWordDefinition, loadWordDefinitionByWord, loadWordList, responseDecoder, responseDecoderForWordDefinition, subscriptions, update, wordDecoder, wordDefinitionReceived, wordDefinitionView, wordEncoder, wordListReceived, wordListStatusView, wordToJson)

import Html exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


port wordListReceived : (WordList -> msg) -> Sub msg


port wordDefinitionReceived : (WordDefinition -> msg) -> Sub msg


port getWordDefinition : String -> Cmd msg


port getWordList : () -> Cmd msg


type alias WordDefinition =
    { id : String
    , word : String
    , definition : String
    , seeAlso : List String
    }


type alias Word =
    { id : String
    , word : String
    }


type alias WordList =
    List Word


type alias Model =
    { wordList : Maybe WordList
    , currentWord : Maybe WordDefinition
    , errorMessage : Maybe String
    }


initialModel : Model
initialModel =
    { wordList = Nothing
    , currentWord = Nothing
    , errorMessage = Nothing
    }


loadWordList : Cmd Msg
loadWordList =
    -- let
    --     url =
    --         "https://dev.himalayanacademy.com/api/index.php/lexicon/words"
    --     request =
    --         Http.get url responseDecoder
    -- in
    -- Http.send HandleWordListResponse request
    getWordList ()


responseDecoder : Decoder WordList
responseDecoder =
    Decode.list wordDecoder


wordDecoder : Decoder Word
wordDecoder =
    Decode.succeed Word
        |> required "lexicon_id" Decode.string
        |> required "word" Decode.string


wordToJson : WordDefinition -> String
wordToJson word =
    Encode.encode 4 (wordEncoder word)


wordEncoder : WordDefinition -> Encode.Value
wordEncoder word =
    Encode.object
        [ ( "id", Encode.string word.id )
        , ( "word", Encode.string word.word )
        , ( "definition", Encode.string word.definition )
        , ( "seeAlso", Encode.list Encode.string word.seeAlso )
        ]



--- ! WORD DEFINITION --


loadWordDefinitionByWord : String -> Maybe WordList -> Cmd Msg
loadWordDefinitionByWord word wordList =
    let
        list =
            case wordList of
                Just l ->
                    l

                Nothing ->
                    []

        found =
            List.head <| List.filter (\i -> i.word == word) list
    in
    case found of
        Just f ->
            loadWordDefinition f.id

        Nothing ->
            Cmd.none


loadWordDefinition : String -> Cmd Msg
loadWordDefinition id =
    -- let
    --     url =
    --         "https://dev.himalayanacademy.com/api/index.php/lexicon/word/" ++ id
    --     request =
    --         Http.get url responseDecoderForWordDefinition
    -- in
    -- Http.send HandleWordDefinitionResponse request
    getWordDefinition id


responseDecoderForWordDefinition : Decoder WordDefinition
responseDecoderForWordDefinition =
    Decode.succeed WordDefinition
        |> required "lexicon_id" Decode.string
        |> required "word" Decode.string
        |> required "definition" Decode.string
        |> optional "see_also" (Decode.list Decode.string) []


type Msg
    = HandleWordListResponse (Result Http.Error WordList)
    | HandleWordDefinitionResponse (Result Http.Error WordDefinition)
    | WordListReceived WordList
    | WordDefinitionReceived WordDefinition


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WordListReceived wl ->
            ( { model | wordList = Just wl }, Cmd.none )

        WordDefinitionReceived w ->
            ( { model | currentWord = Just w }, Cmd.none )

        HandleWordListResponse result ->
            case result of
                Ok results ->
                    ( { model | wordList = Just results }, Cmd.none )

                Err error ->
                    case error of
                        Http.BadPayload errMsg _ ->
                            ( { model | errorMessage = Just errMsg }, Cmd.none )

                        _ ->
                            ( { model | errorMessage = Just "something happened" }, Cmd.none )

        HandleWordDefinitionResponse result ->
            case result of
                Ok results ->
                    ( { model | currentWord = Just results }, Cmd.none )

                Err error ->
                    case error of
                        Http.BadPayload errMsg _ ->
                            ( { model | errorMessage = Just errMsg }, Cmd.none )

                        _ ->
                            ( { model | errorMessage = Just "something happened" }, Cmd.none )


wordListStatusView : Model -> Html Msg
wordListStatusView model =
    case model.wordList of
        Nothing ->
            text "no data"

        Just data ->
            text "received"


wordDefinitionView : Model -> Html Msg
wordDefinitionView model =
    case model.currentWord of
        Nothing ->
            text "no data"

        Just entry ->
            ul []
                [ li [] [ text entry.word ]
                , li [] [ text entry.definition ]
                ]


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ wordListReceived (\wl -> WordListReceived wl)
        , wordDefinitionReceived (\w -> WordDefinitionReceived w)
        ]
