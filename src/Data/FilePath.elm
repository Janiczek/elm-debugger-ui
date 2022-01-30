module Data.FilePath exposing (FilePath, fromString, unwrap)


type FilePath
    = FilePath String


fromString : String -> FilePath
fromString string =
    FilePath string


unwrap : FilePath -> String
unwrap (FilePath string) =
    string
