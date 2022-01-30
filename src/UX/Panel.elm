module UX.Panel exposing (view)

import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events


view :
    { title : String
    , isExpanded : Bool
    , toggle : msg
    }
    -> List (Html msg)
    -> Html msg
view config children =
    let
        arrow : String
        arrow =
            if config.isExpanded then
                "▼"

            else
                "▶"
    in
    Html.div
        [ Attrs.class "flex flex-col" ]
        [ Html.div
            [ Attrs.class "pr-2 py-1 flex flex-row gap-2 text-slate-400 bg-slate-200 text-sm font-bold uppercase tracking-widest select-none border-b border-slate-300 hover:bg-amber-50 transition-colors duration-75"
            , Events.onClick config.toggle
            ]
            [ Html.div
                [ Attrs.class "text-slate-400 w-6 text-center" ]
                [ Html.text arrow ]
            , Html.div [] [ Html.text config.title ]
            ]
        , if config.isExpanded then
            Html.div [] children

          else
            Html.text ""
        ]
