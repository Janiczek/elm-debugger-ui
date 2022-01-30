module Data.FilePath exposing (Comparable, FilePath, fromString, unwrap)


type FilePath
    = FilePath String


type alias Comparable =
    String


fromString : String -> FilePath
fromString string =
    FilePath string


unwrap : FilePath -> String
unwrap (FilePath string) =
    string
