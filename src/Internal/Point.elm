module Internal.Point exposing (..)

{-| -}

import Internal.Coordinate
import Internal.Element as Element
import Color


{-| -}
type alias Point element data =
    { coordinates : Internal.Coordinate.Point -- TODO rename
    , source : data
    , element : Element.Element element
    }


{-| -}
asTuple : Point element data -> ( Float, Float )
asTuple { coordinates } =
    ( coordinates.x, coordinates.y )
