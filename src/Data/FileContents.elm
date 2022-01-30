module Data.FileContents exposing (FileContents, fromString, line, unwrap)


type FileContents
    = FileContents String


fromString : String -> FileContents
fromString string =
    FileContents string


unwrap : FileContents -> String
unwrap (FileContents string) =
    string


line : Int -> FileContents -> Maybe String
line lineNumber (FileContents string) =
    string
        |> String.lines
        |> List.drop (lineNumber - 1)
        |> List.head
