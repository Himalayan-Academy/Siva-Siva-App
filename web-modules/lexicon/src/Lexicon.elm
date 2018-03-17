module Lexicon exposing (..)

import Http
import Html exposing (..)
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)


type alias WordDefinition =
    { id : String
    , word : String
    , definition : String
    , seeAlso : Maybe (List String)
    }


type alias Word =
    { id : String
    , word : String
    }


type alias WordList =
    List Word

type alias Model =
  { wordList: Maybe WordList
  , currentWord : Maybe WordDefinition
  , errorMessage: Maybe String
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
            "http://dev.himalayanacademy.com/api/index.php/lexicon/words"

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


--- ! WORD DEFINITION --

loadWordDefinition : String -> Cmd Msg
loadWordDefinition id =
    let
        url =
            "http://dev.himalayanacademy.com/api/index.php/lexicon/word/" ++ id

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
        |> hardcoded Nothing


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
                            ( { model | errorMessage = Just errMsg}, Cmd.none )

                        _ ->
                            ( { model | errorMessage = Just "something happened"}, Cmd.none )

        HandleWordDefinitionResponse result ->
                    case result of
                        Ok results ->
                            ( { model | currentWord = Just (Debug.log "currentWord:" results) }, Cmd.none )

                        Err error ->
                            case error of
                                Http.BadPayload errMsg _ ->
                                    ( { model | errorMessage = Just errMsg}, Cmd.none )

                                _ ->
                                    ( { model | errorMessage = Just "something happened"}, Cmd.none )




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
                [ li [] [text entry.word]
                , li [] [text entry.definition]
                ]