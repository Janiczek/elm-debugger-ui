module Data.FileContents exposing (FileContents, fromString, unwrap)


type FileContents
    = FileContents String


fromString : String -> FileContents
fromString string =
    FileContents string


unwrap : FileContents -> String
unwrap (FileContents string) =
    string
