module Data.File exposing (File)

import Data.FileContents exposing (FileContents)
import Data.FileName exposing (FileName)
import Data.FilePath exposing (FilePath)


type alias File =
    { path : FilePath
    , name : FileName
    , contents : FileContents
    }
