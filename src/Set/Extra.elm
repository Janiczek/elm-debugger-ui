module Set.Extra exposing (toggle)

import Set exposing (Set)


toggle : comparable -> Set comparable -> Set comparable
toggle item set =
    if Set.member item set then
        Set.remove item set

    else
        Set.insert item set
