module UX.Panel exposing (view)

import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events


view : { title : String } -> List (Html msg) -> Html msg
view config children =
    Html.div
        [ Attrs.class "flex flex-col" ]
        [ Html.div
            [ Attrs.class "px-2 py-1 text-slate-400 bg-slate-200 text-sm font-bold uppercase tracking-widest select-none border-b border-slate-300" ]
            [ Html.text config.title ]
        , Html.div [] children
        ]
