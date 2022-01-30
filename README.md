# elm-debugger-ui

<img src="https://raw.github.com/Janiczek/elm-debugger-ui/master/screenshot.png" alt="Screenshot">

Features a fully functional stateless TreeBrowser component:

<img src="https://raw.github.com/Janiczek/elm-debugger-ui/master/bindings.png" alt="Bindings">

Types your interpreter/VM would need to provide to the app:

```elm
type alias StackFrame =
    { functionName : String
    , extraInfo : Maybe String
    , fileName : String
    , filePath : String
    , fileLine : Int
    , fileColumn : Int
    , bindings : Dict String Binding
    }


type Binding
    = Single
        { name : String
        , type_ : String
        , value : String
        }
    | Collection
        { name : String
        , type_ : String
        , secondaryType : Maybe String
        , children : List Binding
        }


type alias Breakpoint =
    { filePath : String
    , fileName : String
    , fileLine : Int
    }
```

Effects your interpreter/VM needs to provide:

* step
* run (unpause)
