module Internal.Data exposing (..)

{-| -}

import Internal.Coordinate exposing (..)
import Color


{-| -}
type alias Data chart data =
  { chart
  | user : data
  , point : Point
  , seriesIndex : Int
  , label : String
  , color : Color.Color
  }


{-| -}
type alias BarChart data =
  { user : data
  , point : Point
  , seriesIndex : Int
  , label : String
  , color : Color.Color
  }


{-| -}
type alias LineChart data =
  { isReal : Bool
  , user : data
  , point : Point
  , seriesIndex : Int
  , label : String
  , color : Color.Color
  }


{-| -}
type alias ScatterChart data =
  { isOutlier : Bool
  , user : data
  , point : Point
  , seriesIndex : Int
  , label : String
  , color : Color.Color
  }


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
