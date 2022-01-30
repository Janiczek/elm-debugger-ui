module Data.FileName exposing (FileName, fromString, unwrap)


type FileName
    = FileName String


fromString : String -> FileName
fromString string =
    FileName string


unwrap : FileName -> String
unwrap (FileName string) =
    string
