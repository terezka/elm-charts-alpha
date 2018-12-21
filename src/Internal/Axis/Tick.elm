module Internal.Axis.Tick exposing
  ( Config, Properties, Direction(..), isPositive
  , custom, int, float, long, gridless, labelless, opposite
  , properties
  )

{-| -}

import Svg exposing (Svg, Attribute)
import Internal.Svg as Svg
import Chart.Colors as Colors
import Color



{-| -}
type Config msg =
  Config (Properties msg)


{-| -}
type alias Properties msg =
  { color : Color.Color
  , width : Float
  , length : Float
  , grid : Bool
  , direction : Direction
  , label : String -> Svg msg
  }



-- DIRECTION


{-| -}
type Direction
  = Negative
  | Positive



-- INTERNAL


isPositive : Direction -> Bool
isPositive direction =
  case direction of
    Positive -> True
    Negative -> False



-- TICKS


{-| -}
int : Config msg
int =
  custom
    { color = Colors.gray
    , width = 1
    , length = 5
    , grid = True
    , direction = Negative
    , label = Svg.label "inherit"
    }


{-| -}
float : Config msg
float =
  custom
    { color = Colors.gray
    , width = 1
    , length = 5
    , grid = True
    , direction = Negative
    , label = Svg.label "inherit"
    }


{-| -}
gridless : Config msg
gridless =
  custom
    { color = Colors.gray
    , width = 1
    , length = 5
    , grid = False
    , direction = Negative
    , label = Svg.label "inherit"
    }


{-| -}
labelless : Config msg
labelless =
  custom
    { color = Colors.gray
    , width = 1
    , length = 5
    , grid = True
    , direction = Negative
    , label = always (Svg.text "")
    }


{-| -}
long : Config msg
long =
  custom
    { color = Colors.gray
    , width = 1
    , length = 20
    , grid = True
    , direction = Negative
    , label = Svg.label "inherit"
    }


{-| -}
opposite : Config msg
opposite =
  custom
    { color = Colors.gray
    , width = 1
    , length = 5
    , grid = True
    , direction = Positive
    , label = Svg.label "inherit"
    }


{-| -}
custom : Properties msg -> Config msg
custom =
  Config



-- INTERNAL


{-| -}
properties : Config msg -> Properties msg
properties (Config properties_) =
  properties_
