module HardcodedData exposing (breakpoints, callStack, openFiles)

import Data.Binding as Binding
import Data.Breakpoint exposing (Breakpoint)
import Data.File exposing (File)
import Data.FileName as FileName
import Data.FilePath as FilePath
import Data.StackFrame exposing (StackFrame)
import Dict
import List.Zipper as Zipper exposing (Zipper)


openFiles : Zipper File
openFiles =
    Zipper.fromCons
        { name = FileName.fromString "Main.elm", path = FilePath.fromString "src/Main.elm" }
        [ { name = FileName.fromString "User.elm", path = FilePath.fromString "src/Data/User.elm" }
        , { name = FileName.fromString "Extra.elm", path = FilePath.fromString "src/Http/Extra.elm" }
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
    , { fileName = FileName.fromString "FilePath.elm"
      , filePath = FilePath.fromString "src/Data/FilePath.elm"
      , fileLine = 10
      }
    ]
