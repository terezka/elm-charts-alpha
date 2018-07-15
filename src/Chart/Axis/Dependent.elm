module Chart.Axis.Dependent exposing (Config, default, custom)

{-| This is the configuration for the dependent axis of a blocks chart.
It is _not_ used for the dots or line charts.

@docs Config, default, custom


-}


import Internal.Axis.Dependent as Dependent
import Internal.Axis.Ticks as Ticks
import Internal.Axis.Line as AxisLine
import Internal.Axis.Title as Title
import Internal.Axis.Range as Range
import Internal.Unit as Unit


{-| -}
type alias Config msg =
  Dependent.Config msg


{-| The default configuration. Pass the title and
the unit of the axis.

    Chart.Blocks.viewCustom
      { ...
      , dependentAxis = Chart.Axis.Dependent.default "Income" Chart.Axis.Unit.dollars
      , ...
      }

-}
default : String -> Unit.Config -> Config msg
default =
  Dependent.default


{-| Customize your dependent axis. The properties are:

  - title: The title of your axis. See the `Chart.Axis.Title` module.
  - unit: The unit of your axis. See the `Chart.Axis.Unit` module.
  - range: The range of your axis. See the `Chart.Axis.Range` module.
  - axisLine: The line of your axis. See the `Chart.Axis.Line` module.
  - ticks: The ticks on your axis. See the `Chart.Axis.Ticks` module.

-}
custom : Properties msg -> Config msg
custom =
  Dependent.custom


{-| -}
type alias Properties msg =
  { title : Title.Config msg
  , unit : Unit.Config
  , range : Range.Config
  , axisLine : AxisLine.Config msg
  , ticks : Ticks.Config msg
  }

