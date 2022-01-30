module UX.TabList exposing (Tab, view)

import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Json.Decode as Decode


type alias Tab msg =
    { label : String
    , tooltip : String
    , isActive : Bool
    , onActivate : msg
    , onClose : Maybe msg
    }


view : List (Tab msg) -> Html msg
view tabs =
    Html.div
        [ Attrs.class "flex flex-row bg-slate-200 text-sm select-none divide-x divide-slate-300 border-b border-b-slate-300" ]
        (List.map tabView tabs
            ++ -- to give the rightmost item a right border:
               [ Html.div [] [] ]
        )


tabView : Tab msg -> Html msg
tabView tab =
    Html.div
        [ Attrs.class "px-2 py-1 gap-2 flex flex-row cursor-pointer text-slate-700 hover:bg-amber-50 transition-colors duration-75"
        , Attrs.class <| tabStatusClass tab
        , Attrs.title tab.tooltip
        , Events.onClick tab.onActivate
        ]
        [ Html.text tab.label
        , case tab.onClose of
            Nothing ->
                Html.text ""

            Just onClose ->
                Html.div
                    [ Events.stopPropagationOn "click" (Decode.succeed ( onClose, True ))
                    , Attrs.class "hover:text-red-500 cursor-pointer"
                    ]
                    [ Html.text "×" ]
        ]


tabStatusClass : { r | isActive : Bool } -> String
tabStatusClass { isActive } =
    if isActive then
        "bg-sky-100 font-semibold"

    else
        "bg-slate-100"
