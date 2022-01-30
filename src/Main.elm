module Main exposing (main)

import Browser
import Data.Binding as Binding exposing (Binding)
import Data.Breakpoint exposing (Breakpoint)
import Data.File exposing (File)
import Data.FileContents as FileContents exposing (FileContents)
import Data.FileName as FileName
import Data.FilePath as FilePath exposing (FilePath)
import Data.StackFrame as StackFrame exposing (StackFrame)
import Dict exposing (Dict)
import HardcodedData
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import List.Zipper as Zipper exposing (Zipper)
import Set exposing (Set)
import Set.Extra
import UX.Panel
import UX.TabList
import UX.TreeBrowser
import Zipper.Extra


type alias Flags =
    ()


type alias Model =
    { openFiles : Zipper File
    , callStack : Zipper StackFrame
    , breakpoints : List Breakpoint
    , openBindingPaths : Dict StackFrame.ComparableId (Set (List String))
    }


type Msg
    = GoToTab FilePath
    | CloseTab FilePath
    | GoToFrame StackFrame.Id
    | ToggleBindingPath StackFrame.ComparableId (List String)


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
    ( { openFiles = HardcodedData.openFiles
      , callStack = HardcodedData.callStack
      , breakpoints = HardcodedData.breakpoints
      , openBindingPaths = Dict.empty
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GoToTab filePath ->
            ( { model
                | openFiles =
                    model.openFiles
                        |> Zipper.findFirst (\file -> file.path == filePath)
                        |> Maybe.withDefault model.openFiles
              }
            , Cmd.none
            )

        CloseTab filePath ->
            ( { model
                | openFiles =
                    model.openFiles
                        |> Zipper.Extra.filter (\file -> file.path /= filePath)
                        |> Maybe.withDefault model.openFiles
              }
            , Cmd.none
            )

        GoToFrame ( filePath, fileLine, fileColumn ) ->
            ( { model
                | callStack =
                    model.callStack
                        |> Zipper.findFirst
                            (\frame ->
                                (frame.filePath == filePath)
                                    && (frame.fileLine == fileLine)
                                    && (frame.fileColumn == fileColumn)
                            )
                        |> Maybe.withDefault model.callStack
              }
            , Cmd.none
            )

        ToggleBindingPath frameId path ->
            ( { model
                | openBindingPaths =
                    model.openBindingPaths
                        |> Dict.update frameId (Maybe.withDefault Set.empty >> Set.Extra.toggle path >> Just)
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    Html.div
        [ Attrs.class "flex h-screen flex-col" ]
        [ Html.div
            [ Attrs.class "p-2 text-sky-800 bg-sky-400 select-none font-bold uppercase tracking-widest" ]
            [ Html.text "Debugger" ]
        , Html.div
            [ Attrs.class "flex flex-1 flex-row divide-x divide-slate-300 items-stretch overflow-hidden" ]
            [ Html.div
                [ Attrs.class "flex-1 flex flex-col" ]
                [ tabListView model
                , codeView model
                ]
            , Html.div
                [ Attrs.class "w-64 flex flex-col bg-slate-100" ]
                [ Html.div
                    [ Attrs.class "flex flex-1 divide-y divide-slate-300 flex-col items-stretch" ]
                    [ UX.Panel.view
                        { title = "Call stack" }
                        [ callStackView model ]
                    , UX.Panel.view
                        { title = "Bindings" }
                        [ bindingsView model ]
                    , UX.Panel.view
                        { title = "Breakpoints" }
                        [ breakpointsView model ]
                    ]
                ]
            ]
        ]


callStackView : { r | callStack : Zipper StackFrame } -> Html Msg
callStackView { callStack } =
    Html.div
        [ Attrs.class "text-sm text-slate-800 divide-y divide-slate-200" ]
        (callStack
            |> Zipper.Extra.toList_
                { inactive = Tuple.pair False
                , active = Tuple.pair True
                }
            |> List.map
                (\( isActive, frame ) ->
                    Html.div
                        [ Attrs.class "flex flex-col px-2 py-1 hover:bg-amber-50 transition-colors duration-75"
                        , if isActive then
                            Attrs.class "bg-sky-100"

                          else
                            Attrs.class "bg-slate-100"
                        , Events.onClick <| GoToFrame <| StackFrame.id frame
                        ]
                        [ Html.div
                            [ Attrs.title frame.functionName
                            , Attrs.class "overflow-x-hidden whitespace-nowrap text-ellipsis"
                            ]
                            [ Html.text frame.functionName ]
                        , Html.div
                            [ Attrs.class "text-slate-500 text-xs" ]
                            [ Html.text <|
                                FileName.unwrap frame.fileName
                                    ++ ":"
                                    ++ String.fromInt frame.fileLine
                            ]
                        ]
                )
        )


bindingsView :
    { r
        | callStack : Zipper StackFrame
        , openBindingPaths : Dict StackFrame.ComparableId (Set UX.TreeBrowser.Path)
    }
    -> Html Msg
bindingsView { callStack, openBindingPaths } =
    let
        frame : StackFrame
        frame =
            Zipper.current callStack

        -- TODO bindings from outer frames in the same file/function?
        bindings : List Binding
        bindings =
            frame
                |> .bindings
                |> Dict.values

        tree : UX.TreeBrowser.Tree Binding
        tree =
            go (List.map (Tuple.pair []) bindings) []

        go :
            List ( UX.TreeBrowser.Path, Binding )
            -> List ( UX.TreeBrowser.Path, UX.TreeBrowser.Node Binding )
            -> UX.TreeBrowser.Tree Binding
        go todos acc =
            case todos of
                [] ->
                    Dict.fromList acc

                ( pathPrefix, binding ) :: restTodos ->
                    let
                        newPathPrefix =
                            pathPrefix ++ [ Binding.name binding ]

                        newTodos : List ( UX.TreeBrowser.Path, Binding )
                        newTodos =
                            case binding of
                                Binding.Single _ ->
                                    []

                                Binding.Collection r ->
                                    r.children
                                        |> List.map
                                            (\childBinding ->
                                                ( newPathPrefix, childBinding )
                                            )

                        node : ( UX.TreeBrowser.Path, UX.TreeBrowser.Node Binding )
                        node =
                            ( newPathPrefix
                            , { children =
                                    newTodos
                                        |> List.map (\( _, child ) -> newPathPrefix ++ [ Binding.name child ])
                              , value = binding
                              }
                            )
                    in
                    go
                        (restTodos ++ newTodos)
                        (node :: acc)

        openPaths : Set UX.TreeBrowser.Path
        openPaths =
            openBindingPaths
                |> Dict.get (StackFrame.comparableId frame)
                |> Maybe.withDefault Set.empty

        togglePath : UX.TreeBrowser.Path -> Msg
        togglePath =
            ToggleBindingPath (StackFrame.comparableId frame)

        valueView : Binding -> Html Msg
        valueView binding =
            Html.div
                [ Attrs.class "" ]
                ([ [ Html.span
                        [ Attrs.class "text-slate-800" ]
                        [ Html.text <| Binding.name binding ]
                   ]
                 , Binding.value binding
                    |> Maybe.map
                        (\value ->
                            [ Html.span
                                [ Attrs.class "text-slate-500" ]
                                [ Html.text " = " ]
                            , Html.span
                                [ Attrs.class "text-green-700 font-bold" ]
                                [ Html.text value ]
                            ]
                        )
                    |> Maybe.withDefault []
                 , [ Html.span
                        [ Attrs.class "text-slate-500" ]
                        [ Html.text <|
                            " : "
                                ++ Binding.type_ binding
                                ++ (Binding.secondaryType binding
                                        |> Maybe.map (\st -> " (" ++ st ++ ")")
                                        |> Maybe.withDefault ""
                                   )
                        ]
                   ]
                 ]
                    |> List.concat
                )
    in
    UX.TreeBrowser.view
        { tree = tree
        , openPaths = openPaths
        , togglePath = togglePath
        , valueView = valueView
        }


breakpointsView : { r | breakpoints : List Breakpoint } -> Html Msg
breakpointsView { breakpoints } =
    Html.div [ Attrs.class "flex flex-col divide-y" ]
        (List.map
            (\breakpoint ->
                Html.div
                    [ Attrs.class "py-1 px-2 flex flex-col gap-1 hover:bg-amber-50 transition-colors duration-75" ]
                    [ Html.div [ Attrs.class "text-sm" ]
                        [ Html.span
                            [ Attrs.class "text-slate-800" ]
                            [ Html.text <| FileName.unwrap breakpoint.fileName ]
                        , Html.span
                            [ Attrs.class "text-slate-500" ]
                            [ Html.text <| ":" ++ String.fromInt breakpoint.fileLine ]
                        ]
                    , Html.div [ Attrs.class "text-xs text-slate-500 font-mono overflow-x-hidden whitespace-nowrap text-ellipsis" ]
                        [ Html.text "let bogusCode = 42 in String.fromInt bogusCode" ]
                    ]
            )
            breakpoints
            ++ -- to give the bottommost item a bottom border:
               [ Html.div [] [] ]
        )


tabListView : { r | openFiles : Zipper File } -> Html Msg
tabListView { openFiles } =
    let
        toTab : File -> UX.TabList.Tab Msg
        toTab file =
            { label = FileName.unwrap file.name
            , tooltip = FilePath.unwrap file.path
            , isActive = False
            , onActivate = GoToTab file.path
            , onClose = Just <| CloseTab file.path
            }

        activate : UX.TabList.Tab Msg -> UX.TabList.Tab Msg
        activate tab =
            { tab | isActive = True }

        tabs : List (UX.TabList.Tab Msg)
        tabs =
            Zipper.Extra.toList_
                { inactive = toTab
                , active = toTab >> activate
                }
                openFiles
    in
    UX.TabList.view tabs


codeView : { r | openFiles : Zipper File } -> Html Msg
codeView { openFiles } =
    let
        file : File
        file =
            Zipper.current openFiles
    in
    Html.div
        [ Attrs.class "flex flex-1 overflow-hidden" ]
        [ Html.node "x-code"
            [ Attrs.attribute "code" <| FileContents.unwrap file.contents
            , Attrs.class "flex flex-1"
            ]
            []
        ]
