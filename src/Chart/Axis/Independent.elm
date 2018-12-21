module Chart.Axis.Independent exposing (Config, default, custom)

{-|


This is the configuration for the independent axis of a blocks chart.
It is _not_ used for the dots or line charts.

## What are independent and dependent values?
The values of an independent variable are chosen and often controlled by
the investigator, who then observes the effect of each independent variable
on a dependent variable. The dependent variable takes different values in
response to the values of the independent variable that are chosen by the
investigator.

## Their role in blocks charts
Blocks charts are for data where the independent variable is a discrete
variable. Imagine you have a chart where you plot countries against
their GDP. In this case the countries are the discrete values.

In a blocks chart where the blocks are vertical (a column chart),
the independent axis is the x-axis. In a horizontal blocks chart
(a bar chart), the independent axis is the y-axis.


@docs Config, default, custom


-}

import Internal.Axis.Independent as Independent
import Internal.Axis.Tick as Tick
import Internal.Axis.Line as AxisLine
import Internal.Axis.Title as Title
import Internal.Axis.Range as Range


{-| The default configuration. Pass the title and
the unit of the axis.

    Chart.Blocks.viewCustom
      { ...
      , independentAxis = Chart.Axis.Independent.default "Country" .country
      , ...
      }

-}
type alias Config data msg =
  Independent.Config data msg


{-| -}
default : String -> (data -> String) -> Config data msg
default =
  Independent.default


{-| -}
custom : Properties data msg -> Config data msg
custom =
  Independent.custom


{-| Customize your dependent axis. The properties are:

  - title: The title of your axis. See the `Chart.Axis.Title` module.
  - range: The range of your axis. See the `Chart.Axis.Range` module.
  - line: The line of your axis. See the `Chart.Axis.Line` module.
  - label: The property on your data which determines the label.
  - tick: The configuration for the ticks on your axis. See the `Chart.Axis.Tick` module.

-}
type alias Properties data msg =
  { title : Title.Config msg
  , range : Range.Config
  , line : AxisLine.Config msg
  , label : data -> String
  , tick : Tick.Config msg -- TODO depend on index and label?
  }
