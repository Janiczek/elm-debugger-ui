module Zipper.Extra exposing (filter, toList_)

import List.Zipper as Zipper exposing (Zipper)


filter : (a -> Bool) -> Zipper a -> Maybe (Zipper a)
filter pred zipper =
    let
        zipperLR =
            zipper
                |> Zipper.mapBefore (List.filter pred)
                |> Zipper.mapAfter (List.filter pred)
    in
    if pred (Zipper.current zipperLR) then
        -- we don't need to remove the current element
        Just zipperLR

    else if List.isEmpty (Zipper.before zipperLR) then
        if List.isEmpty (Zipper.after zipperLR) then
            -- can't do anything - we want to remove the last element
            Nothing

        else
            -- go to right and delete first left
            zipperLR
                |> Zipper.next
                |> Maybe.map (Zipper.mapBefore (List.reverse >> List.drop 1 >> List.reverse))

    else
        -- go to left and delete first right
        zipperLR
            |> Zipper.previous
            |> Maybe.map (Zipper.mapAfter (List.drop 1))


toList_ :
    { active : a -> b
    , inactive : a -> b
    }
    -> Zipper a
    -> List b
toList_ { active, inactive } zipper =
    [ zipper
        |> Zipper.before
        |> List.map inactive
    , [ zipper
            |> Zipper.current
            |> active
      ]
    , zipper
        |> Zipper.after
        |> List.map inactive
    ]
        |> List.concat
