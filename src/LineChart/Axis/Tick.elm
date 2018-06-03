module LineChart.Axis.Tick exposing
  ( Config, Properties
  , Direction, negative, positive
  , int, float, long, gridless, labelless, opposite
  , time, Time, Unit(..), Interval, format
  , custom
  )

{-|

@docs Config, int, float, time

## Special styles
You can also make your own with `custom`!
@docs long, gridless, labelless, opposite

# Customiztion
@docs custom, Properties, Direction, negative, positive

# Time formatting
@docs format, Time, Interval, Unit

-}

import Svg exposing (Svg, Attribute)
import Internal.Axis.Tick as Tick
import Internal.Svg as Svg
import Color



{-| Used in the configuration in the `ticks` property of the
options passed to `Axis.custom`.

    xAxisConfig : Axis.Config Data msg
    xAxisConfig =
      Axis.custom
        { ...
        , ticks = ticksConfig
        }

    ticksConfig : Ticks.Config msg
    ticksConfig =
      Ticks.intCustom 7 Tick.int
      --                ^^^^^^^^
      -- or
      Ticks.timeCustom 7 Tick.time
      -- or
      Ticks.floatCustom 7 Tick.float
      -- or
      Ticks.floatCustom 7 customTick
      -- or ... you get it

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Tick/Example1.elm)._

-}
type alias Config msg =
  Tick.Config msg



-- NUMBERS


{-| -}
int : Int -> Config msg
int =
  Tick.int


{-| -}
float : Float -> Config msg
float =
  Tick.float


{-| -}
gridless : Float -> Config msg
gridless =
  Tick.gridless


{-| -}
labelless : Float -> Config msg
labelless =
  Tick.labelless


{-| -}
opposite : Float -> Config msg
opposite =
  Tick.opposite


{-| -}
long : Float -> Config msg
long =
  Tick.long



-- TIME


{-| You can format your tick label differently based on it's unit. This is
the default formatting. There are lots of different packages to help you out
with this. I ended up using two different! Maybe one day I'll get around to
sending a pull request for week formatting in `Date.Format`..

    format : Unit -> Tick.Time -> String
    format unit tick =
      let time = tick.timestamp
          date = Date.fromTime time
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

-}
type Unit
  = Millisecond
  | Second
  | Minute
  | Hour
  | Day
  | Week
  | Month
  | Year



{-| Explanation:

  - ** timestamp ** is the position where the tick goes on the axis.
  - ** isFirst ** is whether this is the first tick or not.
  - ** interval ** is the interval at which all the ticks are spaced.
  - ** change ** is a `Just` when the tick is changing to a larger unit
    than used in the interval. E.g. if the interval is 2 hours, then
    this will be a `Just Day` when the day changes. Useful if you
    want a different formatting for those ticks!

-}
type alias Time =
  { timestamp : Float
  , isFirst : Bool
  , interval : Interval
  , change : Maybe Unit
  }


{-| The interval at which ticks are spaced. If ticks a spaced with two hours,
this will be `{ unit = Hour, multiple = 2 }`.
-}
type alias Interval =
  { unit : Unit
  , multiple : Int
  }


{-| -}
time : Time -> Config msg
time time =
  custom
    { position = time.timestamp
    , color = Color.gray
    , width = 1
    , length = 5
    , grid = True
    , direction = negative
    , label = Just <| Svg.label "inherit" (format time)
    }



{-| This is the default formatting of the time type. Useful when you want to
change other properties of your time tick, but won't bother with the formatting.

    tickConfig : Tick.Time -> Tick.Config msg
    tickConfig time =
      Tick.custom
        { position = time.timestamp
        , color = Color.blue
        , width = 1
        , length = 7
        , grid = True
        , direction = Tick.positive
        , label = Just <|
            Junk.label Color.blue (Tick.format time)
        }

-}
format : Time -> String
format config =
  Tick.format (toStandardTime config)



-- CUSTOM


{-| Explanation:

  - **position** is the position on the axis.
  - **color** is the color of the little line.
  - **width** is the width of the little line.
  - **length** is the length of the little line.
  - **grid** is whether a grid will be placed by the tick or not.
  - **direction** is the direction of the little line. If the tick in question
    is on the x-axis that means that positive means the tick points up,
    and negative points down.
  - **label** is the label. If set to `Nothing`, no label will be drawn.

-}
type alias Properties msg =
  { position : Float
  , color : Color.Color
  , width : Float
  , length : Float
  , grid : Bool
  , direction : Direction
  , label : Maybe (Svg msg)
  }


{-| The direction of the little line. If the tick in question is on the x-axis
that means that positive means the tick points up, and negative points down.
-}
type alias Direction =
  Tick.Direction


{-| -}
negative : Direction
negative =
  Tick.Negative


{-| -}
positive : Direction
positive =
  Tick.Positive


{-| Make your own tick!

    customTick : Float -> Tick.Config msg
    customTick number =
      let
        color =
          -- Change the color based on value!
          if number < 50 then Colors.purple
          else if number < 70 then Colors.green
          else Colors.pinkLight

        label =
          Junk.label color (toString number)
      in
      Tick.custom
        { position = number
        , color = Colors.black
        , width = 1
        , length = 7
        , grid = True
        , direction = Tick.positive
        , label = Just label
        }


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Tick/Example1.elm)._

-}
custom : Properties msg -> Config msg
custom =
  Tick.custom



-- UNIT CONVERSION


toStandardTime :Time -> Tick.Time
toStandardTime config =
  { change = Maybe.map toStandardUnit config.change
  , interval = Tick.Interval (toStandardUnit config.interval.unit) config.interval.multiple
  , timestamp = config.timestamp
  , isFirst = config.isFirst
  }


toStandardUnit : Unit -> Tick.Unit
toStandardUnit unit =
  case unit of
    Millisecond -> Tick.Millisecond
    Second      -> Tick.Second
    Minute      -> Tick.Minute
    Hour        -> Tick.Hour
    Day         -> Tick.Day
    Week        -> Tick.Week
    Month       -> Tick.Month
    Year        -> Tick.Year


