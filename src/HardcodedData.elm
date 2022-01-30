module HardcodedData exposing (breakpoints, callStack, openFiles)

import Data.Binding as Binding
import Data.Breakpoint exposing (Breakpoint)
import Data.File exposing (File)
import Data.FileContents as FileContents exposing (FileContents)
import Data.FileName as FileName
import Data.FilePath as FilePath
import Data.StackFrame exposing (StackFrame)
import Dict exposing (Dict)
import List.Zipper as Zipper exposing (Zipper)


openFiles : Zipper File
openFiles =
    Zipper.fromCons
        { name = FileName.fromString "Main.elm"
        , path = FilePath.fromString "src/Main.elm"
        , contents = mainContents
        }
        [ { name = FileName.fromString "FileName.elm"
          , path = FilePath.fromString "src/Data/FileName.elm"
          , contents = dataFileNameContents
          }
        , { name = FileName.fromString "Extra.elm"
          , path = FilePath.fromString "src/Zipper/Extra.elm"
          , contents = zipperExtraContents
          }
        ]


callStack : Zipper StackFrame
callStack =
    Zipper.fromCons
        { functionName = "anonymous function (argument `pred` of Zipper.Extra.filter)"
        , fileName = FileName.fromString "Main.elm"
        , filePath = FilePath.fromString "src/Main.elm"
        , fileLine = 83
        , fileColumn = 49
        , bindings =
            [ Binding.Collection
                { name = "file"
                , type_ = "File"
                , secondaryType = Just "record"
                , children =
                    [ Binding.Collection
                        { name = "path"
                        , type_ = "FilePath"
                        , secondaryType = Just "FilePath"
                        , children =
                            [ Binding.Single
                                { name = "_0"
                                , type_ = "String"
                                , value = "\"src/Main.elm\""
                                }
                            ]
                        }
                    , Binding.Collection
                        { name = "name"
                        , type_ = "FileName"
                        , secondaryType = Just "FileName"
                        , children =
                            [ Binding.Single
                                { name = "_0"
                                , type_ = "String"
                                , value = "\"Main.elm\""
                                }
                            ]
                        }
                    ]
                }
            ]
                |> List.map (\binding -> ( Binding.name binding, binding ))
                |> Dict.fromList
        }
        [ { functionName = "Zipper.Extra.filter"
          , fileName = FileName.fromString "Extra.elm"
          , filePath = FilePath.fromString "src/Zipper/Extra.elm"
          , fileLine = 14
          , fileColumn = 8
          , bindings =
                [ Binding.Single
                    { name = "pred"
                    , type_ = "function"
                    , value = "<function>"
                    }
                , Binding.Single
                    { name = "zipper"
                    , type_ = "()"
                    , value = "()"
                    }
                ]
                    |> List.map (\binding -> ( Binding.name binding, binding ))
                    |> Dict.fromList
          }
        , { functionName = "Main.update"
          , fileName = FileName.fromString "Main.elm"
          , filePath = FilePath.fromString "src/Main.elm"
          , fileLine = 83
          , fileColumn = 28
          , bindings =
                [ Binding.Single
                    { name = "msg"
                    , value = "Inc"
                    , type_ = "Msg"
                    }
                , Binding.Collection
                    { name = "model"
                    , type_ = "Model"
                    , secondaryType = Just "record"
                    , children =
                        [ Binding.Single
                            { name = "counter"
                            , type_ = "Int"
                            , value = "5"
                            }
                        ]
                    }
                ]
                    |> List.map (\binding -> ( Binding.name binding, binding ))
                    |> Dict.fromList
          }
        ]


breakpoints : List Breakpoint
breakpoints =
    [ { fileName = FileName.fromString "Main.elm"
      , filePath = FilePath.fromString "src/Main.elm"
      , fileLine = 78
      }
    , { fileName = FileName.fromString "FileName.elm"
      , filePath = FilePath.fromString "src/Data/FileName.elm"
      , fileLine = 10
      }
    ]


mainContents : FileContents
mainContents =
    """
module Main exposing (main)

import Browser
import Html exposing (Html)

main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GoToTab filePath ->
            (1, Cmd.none)
"""
        |> String.dropLeft 1
        |> FileContents.fromString


dataFileNameContents : FileContents
dataFileNameContents =
    """
module Data.FileName exposing (FileName, fromString, unwrap)


type FileName
    = FileName String


fromString : String -> FileName
fromString string =
    FileName string


unwrap : FileName -> String
unwrap (FileName string) =
    string
"""
        |> String.dropLeft 1
        |> FileContents.fromString


zipperExtraContents : FileContents
zipperExtraContents =
    """
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
"""
        |> String.dropLeft 1
        |> FileContents.fromString
