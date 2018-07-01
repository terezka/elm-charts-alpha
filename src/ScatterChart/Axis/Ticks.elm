module ScatterChart.Axis.Ticks exposing
  ( Config, default
  , int, time, float
  , intCustom, timeCustom, floatCustom, custom
  )

{-|

@docs Config, default

# Custom amount

Choose the approximate amount of ticks on your axis!

    ticksConfig : Ticks.Config msg
    ticksConfig =
      Ticks.int 7   -- makes ca. 7 ticks at nice integers
      -- or
      Ticks.time 7  -- makes ca. 7 ticks at nice datetimes
      -- or
      Ticks.float 7 -- makes ca. 7 ticks at nice float


_See full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Ticks/Example1.elm)._

@docs int, time, float

# Custom tick

Now you get to decide how the ticks should look. Remember that all formatting of
the value in the label is done in `Axis.Tick`!

    ticksConfig : Ticks.Config msg
    ticksConfig =
      Ticks.intCustom 7 customTick


_See full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Ticks/Example1.elm)._

@docs intCustom, timeCustom, floatCustom

# Custom positions
@docs custom

-}

import ScatterChart.Coordinate as Coordinate exposing (..)
import Internal.Axis.Ticks as Ticks
import Internal.Axis.Values as Values
import Internal.Axis.Tick
import ScatterChart.Axis.Tick as Tick



{-| Part of the configuration in `Axis.custom`.

    axisConfig : Axis.Config Data msg
    axisConfig =
      Axis.custom
        { ..
        , ticks = Ticks.default
        , ...
        }

-}
type alias Config msg =
  Ticks.Config msg


{-| -}
type alias Set msg =
  Ticks.Set msg



-- API / AXIS


{-| Makes around five ticks at "nice" numbers.

** What are "nice" numbers/integers/datetimes? **

"Nice" numbers are intervals which begin with 10, 5, 3, 2, 1
(adjusted to magnitude, of course!). For dates, it means whole days, weeks,
months or hours, minutes, and seconds.

-} -- TODO make better approximate
default : Config msg
default =
  custom <| \data axis ->
    [ set Tick.float toString identity (Values.float (Values.around 5) axis) ]


{-| -}
int : Int -> Config msg
int n =
  custom <| \data axis ->
    [ set Tick.int toString toFloat (Values.int (Values.around n) axis) ]


{-| -}
time : Int -> Config msg
time n =
   custom <| \data axis ->
    [ set Tick.int Tick.format .timestamp (List.map toLocalTime (Values.time n axis)) ]


{-| -}
float : Int -> Config msg
float n =
   custom <| \data axis ->
    [ set Tick.float toString identity (Values.float (Values.around n) axis) ]


{-| -}
intCustom : Tick.Config msg -> Int -> Config msg
intCustom tick n =
  custom <| \data axis ->
    [ set tick toString identity (Values.float (Values.around n) axis) ]


{-| -}
floatCustom : Tick.Config msg -> Int -> Config msg
floatCustom tick n =
  custom <| \data axis ->
    [ set tick toString identity (Values.float (Values.around n) axis) ]


{-| -}
timeCustom : Tick.Config msg -> Int -> Config msg
timeCustom tick n =
  custom <| \data axis ->
    [ set tick Tick.format .timestamp (List.map toLocalTime (Values.time n axis)) ]


{-| Make your own combination of ticks.

    ticksConfig : Maybe Info -> Ticks.Config msg
    ticksConfig maybeHovered =
      let
        hoverOne =
          case maybeHovered of
            Just hovered -> [ Tick.float hovered.age ]
            Nothing -> []

        framing range =
          List.map Tick.float [ range.min, range.max ]
      in
      Ticks.custom <| \dataRange axisRange ->
        framing dataRange ++ hoverOne


_See full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Ticks/Example2.elm)._

** What if I still want nice values?**

You can use `Axis.Values` to produce "nice" values within a given range.

-}
custom : (Coordinate.Range -> Coordinate.Range -> List (Set msg)) -> Config msg
custom =
  Ticks.custom


{-| -}
set : Tick.Config msg -> (data -> String) -> (data -> Float) -> List data -> Set msg
set =
  Ticks.set


-- UNIT CONVERSION


toLocalTime : Internal.Axis.Tick.Time -> Tick.Time
toLocalTime config =
  { change = Maybe.map toLocalUnit config.change
  , interval = Tick.Interval (toLocalUnit config.interval.unit) config.interval.multiple
  , timestamp = config.timestamp
  , isFirst = config.isFirst
  }


toLocalUnit : Internal.Axis.Tick.Unit -> Tick.Unit
toLocalUnit unit =
  case unit of
    Internal.Axis.Tick.Millisecond -> Tick.Millisecond
    Internal.Axis.Tick.Second      -> Tick.Second
    Internal.Axis.Tick.Minute      -> Tick.Minute
    Internal.Axis.Tick.Hour        -> Tick.Hour
    Internal.Axis.Tick.Day         -> Tick.Day
    Internal.Axis.Tick.Week        -> Tick.Week
    Internal.Axis.Tick.Month       -> Tick.Month
    Internal.Axis.Tick.Year        -> Tick.Year

