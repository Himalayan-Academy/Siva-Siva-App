module Lexicon exposing (..)

import Html exposing (..)
import Http
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)
import Json.Encode as JE


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
    let
        url =
            "https://dev.himalayanacademy.com/api/index.php/lexicon/words"

        request =
            Http.get url responseDecoder
    in
    Http.send HandleWordListResponse request


responseDecoder : Decoder WordList
responseDecoder =
    Json.Decode.list wordDecoder


wordDecoder : Decoder Word
wordDecoder =
    decode Word
        |> required "lexicon_id" Json.Decode.string
        |> required "word" Json.Decode.string


wordToJson : WordDefinition -> String
wordToJson word =
    JE.encode 4 (wordEncoder word)


wordEncoder : WordDefinition -> JE.Value
wordEncoder word =
    JE.object
        [ ( "id", JE.string word.id )
        , ( "word", JE.string word.word )
        , ( "definition", JE.string word.definition )
        , ( "seeAlso", JE.list (List.map JE.string word.seeAlso) )
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
    let
        url =
            "https://dev.himalayanacademy.com/api/index.php/lexicon/word/" ++ id

        request =
            Http.get url responseDecoderForWordDefinition
    in
    Http.send HandleWordDefinitionResponse request


responseDecoderForWordDefinition : Decoder WordDefinition
responseDecoderForWordDefinition =
    decode WordDefinition
        |> required "lexicon_id" Json.Decode.string
        |> required "word" Json.Decode.string
        |> required "definition" Json.Decode.string
        |> optional "see_also" (Json.Decode.list Json.Decode.string) []


type Msg
    = HandleWordListResponse (Result Http.Error WordList)
    | HandleWordDefinitionResponse (Result Http.Error WordDefinition)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        HandleWordListResponse result ->
            case result of
                Ok results ->
                    ( { model | wordList = Just (Debug.log "wordlist:" results) }, Cmd.none )

                Err error ->
                    case error of
                        Http.BadPayload errMsg _ ->
                            ( { model | errorMessage = Just errMsg }, Cmd.none )

                        _ ->
                            ( { model | errorMessage = Just "something happened" }, Cmd.none )

        HandleWordDefinitionResponse result ->
            case result of
                Ok results ->
                    ( { model | currentWord = Just (Debug.log "currentWord:" results) }, Cmd.none )

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
