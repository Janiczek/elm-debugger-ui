module Data.Breakpoint exposing (Breakpoint)

import Data.FileName exposing (FileName)
import Data.FilePath exposing (FilePath)


type alias Breakpoint =
    { filePath : FilePath
    , fileName : FileName
    , fileLine : Int
    }
