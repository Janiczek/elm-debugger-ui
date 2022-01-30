module Data.Binding exposing
    ( Binding(..)
    , name
    , secondaryType
    , type_
    , value
    )

import Dict exposing (Dict)


type Binding
    = Single
        { name : String
        , type_ : String
        , value : String
        }
    | Collection
        { name : String
        , type_ : String
        , secondaryType : Maybe String
        , children : List Binding
        }


name : Binding -> String
name binding =
    case binding of
        Single r ->
            r.name

        Collection r ->
            r.name


value : Binding -> Maybe String
value binding =
    case binding of
        Single r ->
            Just r.value

        Collection _ ->
            Nothing


type_ : Binding -> String
type_ binding =
    case binding of
        Single r ->
            r.type_

        Collection r ->
            r.type_


secondaryType : Binding -> Maybe String
secondaryType binding =
    case binding of
        Single _ ->
            Nothing

        Collection r ->
            r.secondaryType
