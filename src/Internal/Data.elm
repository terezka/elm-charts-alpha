module Internal.Data exposing (..)

{-| -}

import Internal.Coordinate exposing (..)



{-| -}
type alias Data chart data =
  { chart
  | user : data
  , point : Point
  }


{-| -}
type alias BarChart =
  { barIndex : Int }


{-| -}
type alias LineChart =
  { isReal : Bool }


{-| -}
type alias ScatterChart =
  { isOutlier : Bool }


{-| -}
type alias Point =
  { x : Float
  , y : Float
  }


{-| -}
isWithinRange : System -> Point -> Bool
isWithinRange system point =
  clamp system.x.min system.x.max point.x == point.x &&
  clamp system.y.min system.y.max point.y == point.y


{-| -}
asTuple : Data chart data -> ( Float, Float )
asTuple { point } =
    ( point.x, point.y )
