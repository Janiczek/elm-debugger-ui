module Data.StackFrame exposing (ComparableId, Id, StackFrame, comparableId, id)

import Data.Binding exposing (Binding)
import Data.FileName exposing (FileName)
import Data.FilePath as FilePath exposing (FilePath)
import Dict exposing (Dict)


type alias StackFrame =
    { functionName : String
    , fileName : FileName
    , filePath : FilePath
    , fileLine : Int
    , fileColumn : Int
    , bindings : Dict String Binding
    }


type alias Id =
    ( FilePath, Int, Int )


type alias ComparableId =
    ( String, Int, Int )


id : StackFrame -> Id
id frame =
    ( frame.filePath
    , frame.fileLine
    , frame.fileColumn
    )


comparableId : StackFrame -> ComparableId
comparableId frame =
    ( FilePath.unwrap frame.filePath
    , frame.fileLine
    , frame.fileColumn
    )
