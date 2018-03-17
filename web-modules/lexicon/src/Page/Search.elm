module Page.Search exposing (..)

--import Html.Events exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Html.Styled.Events exposing (onClick)
import Lexicon exposing (Model, Word, WordList)
import Theme.Colors exposing (..)


type Msg
    = LoadDefinition String
    | LexiconMsg Lexicon.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LexiconMsg subMsg ->
            let
                ( updateLexiconModel, lexiconCmd ) =
                    Lexicon.update subMsg model
            in
            ( model, Cmd.map LexiconMsg lexiconCmd )

        LoadDefinition id ->
            ( model, Cmd.map LexiconMsg (Lexicon.loadWordDefinition id) )


addWordItem : Word -> Html Msg
addWordItem word =
    li [ onClick (LoadDefinition word.id) ] [ text word.word ]


view : Model -> Html Msg
view model =
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
