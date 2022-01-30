module UX.TreeBrowser exposing (Node, Path, Tree, view)

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Set exposing (Set)


type alias Tree value =
    Dict Path (Node value)


type alias Path =
    List String


type alias Node value =
    { children : List Path
    , value : value
    }


view :
    { tree : Tree value
    , valueView : value -> Html msg
    , openPaths : Set Path
    , togglePath : Path -> msg
    }
    -> Html msg
view { tree, valueView, openPaths, togglePath } =
    let
        nodeView : Int -> Path -> Html msg
        nodeView level path =
            case Dict.get path tree of
                Nothing ->
                    Html.text ""

                Just node ->
                    let
                        isExpandable : Bool
                        isExpandable =
                            not <| List.isEmpty node.children

                        isExpanded : Bool
                        isExpanded =
                            isExpandable && Set.member path openPaths

                        arrow : String
                        arrow =
                            if isExpanded then
                                "▼"

                            else
                                "▶"

                        spacer : Html msg
                        spacer =
                            Html.div [ Attrs.class "w-4" ] []
                    in
                    if isExpandable then
                        Html.div
                            []
                            [ Html.div
                                [ Attrs.class "flex flex-row hover:bg-amber-50 transition-colors duration-75 cursor-pointer py-1"
                                , Events.onClick <| togglePath path
                                ]
                                [ Html.div
                                    [ Attrs.class "flex flex-row" ]
                                    (List.repeat level spacer)
                                , Html.div
                                    [ Attrs.class "text-slate-400 w-6 text-center" ]
                                    [ Html.text arrow ]
                                , Html.div
                                    [ Attrs.class "" ]
                                    [ valueView node.value ]
                                ]
                            , if isExpanded then
                                Html.div
                                    [ Attrs.class "" ]
                                    (List.map (nodeView (level + 1)) node.children)

                              else
                                Html.text ""
                            ]

                    else
                        Html.div
                            [ Attrs.class "pl-6 py-1 flex flex-row hover:bg-amber-50 transition-colors duration-75" ]
                            [ Html.div
                                [ Attrs.class "flex flex-row" ]
                                (List.repeat level spacer)
                            , valueView node.value
                            ]

        firstLevel : List Path
        firstLevel =
            tree
                |> Dict.filter (\path _ -> List.length path == 1)
                |> Dict.keys
    in
    Html.div
        [ Attrs.class "text-sm flex flex-col divide-y divide-slate-300" ]
        (List.map (nodeView 0) firstLevel)
