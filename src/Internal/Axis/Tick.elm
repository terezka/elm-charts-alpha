module Internal.Axis.Tick exposing
  ( Config, Properties, Direction(..), isPositive
  , custom, int, float, long, gridless, labelless, opposite, time
  , Unit(..), Time, Interval, normal, bold, next, format
  , properties
  )

{-| -}

import Svg exposing (Svg, Attribute)
import Internal.Svg as Svg
import Internal.Colors as Colors
import Color
import Date
import Date.Extra
import Date.Format


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
time : Config msg
time =
  custom
    { color = Color.gray
    , width = 1
    , length = 5
    , grid = True
    , direction = Negative
    , label = Svg.label "inherit"
    }


{-| -}
custom : Properties msg -> Config msg
custom =
  Config


{-| -}
type Unit
  = Millisecond
  | Second
  | Minute
  | Hour
  | Day
  | Week
  | Month
  | Year


{-| -}
type alias Time =
  { timestamp : Float
  , isFirst : Bool
  , interval : Interval
  , change : Maybe Unit
  }


{-| -}
type alias Interval =
  { unit : Unit
  , multiple : Int
  }


{-| -}
format : Time -> String
format { change, interval, timestamp, isFirst } =
  if isFirst then
    bold (next interval.unit) timestamp
  else
    case change of
      Just change -> bold change timestamp
      Nothing     -> normal interval.unit timestamp



-- INTERNAL


{-| -}
properties : Config msg -> Properties msg
properties (Config properties) =
  properties


normal : Unit -> Float -> String
normal unit time =
  let date = Date.fromTime time
      format1 = Date.Format.format
      format2 = Date.Extra.toFormattedString
  in
  case unit of
    Millisecond -> time |> toString
    Second      -> date |> format1 "%S"
    Minute      -> date |> format1 "%M"
    Hour        -> date |> format1 "%l%P"
    Day         -> date |> format1 "%e"
    Week        -> date |> format2 "'Week' w"
    Month       -> date |> format1 "%b"
    Year        -> date |> format1 "%Y"


bold : Unit -> Float -> String
bold unit =
  Date.fromTime >>
    case unit of
      Millisecond -> Basics.toString << Date.toTime
      Second      -> Date.Format.format "%S"
      Minute      -> Date.Format.format "%M"
      Hour        -> Date.Format.format "%l%P"
      Day         -> Date.Format.format "%a"
      Week        -> Date.Extra.toFormattedString "'Week' w"
      Month       -> Date.Format.format "%b"
      Year        -> Date.Format.format "%Y"


next : Unit -> Unit
next unit =
  case unit of
    Millisecond -> Second
    Second      -> Minute
    Minute      -> Hour
    Hour        -> Day
    Day         -> Week
    Week        -> Month
    Month       -> Year
    Year        -> Year

