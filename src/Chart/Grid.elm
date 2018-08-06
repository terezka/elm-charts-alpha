module Chart.Grid exposing (Config, default, none, dots, lines)

{-|

# WARNING! THIS IS AN ALPHA VERSION

*IT HAS MISSING, MISLEADING AND PLAIN WRONG DOCUMENTATION.*
*IT HAS BUGS AND AWKWARDNESS.*
*USE AT OWN RISK.*

@docs Config, default, none, dots, lines

# How do I change where the grid lines/dots are placed?

By default there is a grid by every tick. If you want to change
the position of the grid or remove it all together, alter your tick
configuration of your axis.

The path to the tick in the configuration does through the `x` or `y`
property for vertical and horizontal grids respectivily and then in the
`axis` property.

See `Chart.Axis` -> `Chart.Axis.Ticks` -> `Chart.Axis.Tick`.

-}

import Internal.Grid as Grid
import Color


{-| Use in the `Chart.Config` passed to `Chart.viewCustom`.

    chartConfig : Chart.Config Data msg
    chartConfig =
      { ...
      , grid = Grid.default
      , ...
      }

-}
type alias Config =
  Grid.Config


{-| Gets you some vague gray grid lines.
-}
default : Config
default =
  Grid.default


{-| No grid! (Ok, fine, it's there, but it's transparent!) -}
none : Config
none =
  Grid.none


{-| Gets you a grid dots of a given radius and color.
-}
dots : Float -> Color.Color -> Config
dots =
  Grid.dots


{-| Gets you grid lines of a given width and color.
-}
lines : Float -> Color.Color -> Config
lines =
  Grid.lines
