module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events


type alias Flags =
    ()


type alias Model =
    { counter : Int }


type Msg
    = Inc
    | Dec


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init () =
    ( { counter = 0 }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Inc ->
            ( { model | counter = model.counter + 1 }, Cmd.none )

        Dec ->
            ( { model | counter = model.counter - 1 }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    Html.div
        [ Attrs.class "p-2 flex gap-2 items-center" ]
        [ Html.button
            [ Events.onClick Dec
            , Attrs.class "px-1 border bg-sky-200 border-sky-400 hover:bg-sky-300 hover:border-sky-500"
            ]
            [ Html.text "-" ]
        , Html.text <| String.fromInt model.counter
        , Html.button
            [ Events.onClick Inc
            , Attrs.class "px-1 border bg-sky-200 border-sky-400 hover:bg-sky-300 hover:border-sky-500"
            ]
            [ Html.text "+" ]
        ]
