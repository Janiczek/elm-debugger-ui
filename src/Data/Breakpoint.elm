module Data.Breakpoint exposing (Breakpoint)

import Data.FileName as FileName exposing (FileName)
import Data.FilePath as FilePath exposing (FilePath)


type alias Breakpoint =
    { filePath : FilePath
    , fileName : FileName
    , fileLine : Int
    }
