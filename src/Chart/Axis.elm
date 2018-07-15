module Chart.Axis exposing (Config, default, full, time, custom, picky)

{-|

_If you're confused as to what "axis range" and "data range" means,
check out `Axis.Range` for an explanation!_

@docs Config, default, full, time, picky, custom

-}


import Internal.Unit as Unit
import Internal.Axis as Axis
import Internal.Axis.Title as Title
import Chart.Axis.Range as Range
import Chart.Axis.Line as AxisLine
import Chart.Axis.Ticks as Ticks



{-| Use in the `Chart.Config` passed to `Chart.viewCustom`.

    chartConfig : Chart.Config value data msg
    chartConfig =
      { ...
      , x = Chart.Axis.default "Age" Chart.Axis.Unit.years .age
      , y = Chart.Axis.default "Weight" Chart.Axis.Unit.kilograms .weight
      , ...
      }

-}
type alias Config value data msg =
  Axis.Config value data msg


{-| Draws a line the full length of your _data range_ and adds a little space on
both sides of that line. Also adds some nice ticks to it.

Pass the length of your axis in pixels, the title and it's variable.

    xAxisConfig : Axis.Config Float Data msg
    xAxisConfig =
      Axis.default "Age (years)" Chart.Axis.Unit.years .age


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Axis/Example1.elm)._

-}
default : String -> Unit.Config -> (data -> value) -> Config value data msg
default =
  Axis.default


{-| Draws a line the full length of your _axis range_ and adds some nice ticks to it.

Pass the length of your axis in pixels, the title and it's variable.


    xAxisConfig : Axis.Config Float Data msg
    xAxisConfig =
      Axis.full "Age (years)" Chart.Axis.Unit.years .age


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Axis/Example2.elm)._

-}
full : String -> Unit.Config -> (data -> value) -> Config value data msg
full =
  Axis.full


{-| Draws a line the full length of your _data range_ and adds some nice datetime ticks to it.

Pass the length of your axis in pixels, the title and it's variable.


    xAxisConfig : Axis.Config Float Data msg
    xAxisConfig =
      Axis.time 650 "Date" Chart.Axis.Unit.none .date


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Axis/Example3.elm)._

-}
time : String -> Unit.Config -> (data -> value) -> Config value data msg
time =
  Axis.time


{-| Draws the full length of your axis range and adds some ticks at the positions
specified in the last argument.

Pass the length of your axis in pixels, the title, it's variable and the
numbers where you'd like ticks to show up.


    xAxisConfig : Axis.Config Float Data msg
    xAxisConfig =
      Axis.picky 650 "Age (years)" Chart.Axis.Unit.years .age [ 4, 25, 46 ]


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Axis/Example4.elm)._

**Note:** This is of course not the only way for you to decide exactly where the
ticks should go on the axis! If you need to customize ticks further, check out
the `ticks` property in `Axis.custom`.

-}
picky : String -> Unit.Config -> (data -> value) -> List Float -> Config value data msg
picky =
  Axis.picky


{-|

Properties:

  - **title**: Adds a title on your axis. </br>
    _See `Chart.Axis.Title` for more information and examples._
  - **variable**: Determines what data is drawn in the chart! </br>
  - **unit**: The unit of this dimension. </br>
    _See `Chart.Axis.Unit` for more information and examples._
  - **range**: Determines the axis range. </br>
    _See `Chart.Axis.Range` for more information and examples._
  - **line**: Customizes your axis line. </br>
    _See `Chart.Axis.Line` for more information and examples._
  - **ticks**: Customizes your ticks. </br>
    _See `Chart.Axis.Ticks` for more information and examples._


    xAxisConfig : Axis.Config Float Data msg
    xAxisConfig =
      Axis.custom
        { title = Chart.Axis.Title.default "Year"
        , variable = Just << .date
        , unit = Chart.Axis.Unit.none
        , range = Chart.Axis.Range.padded 20 20
        , line = Chart.Axis.Line.full Colors.black
        , ticks = Chart.Axis.Ticks.time 5
        }


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Axis/Example8.elm)._

-}
custom : Properties value data msg -> Config value data msg
custom =
  Axis.custom


{-| -}
type alias Properties value data msg =
  { title : Title.Config msg
  , unit : Unit.Config
  , variable : data -> value
  , range : Range.Config
  , line : AxisLine.Config msg
  , ticks : Ticks.Config msg
  }
