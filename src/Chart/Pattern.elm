module Chart.Pattern exposing (Config, default, custom)


{-|



This configures the striped pattern of the block, if patterned.
_See `Chart.Blocks.series` on how to make a block patterned._

@docs Config, default, custom

-}

import Internal.Pattern


{-| Use in the `Chart.Blocks.Config` passed to `Chart.Blocks.viewCustom`.

    chartConfig : Chart.Config value data msg
    chartConfig =
      { ...
      , pattern = Chart.Pattern.default
      , ...
      }

-}
type alias Config =
    Internal.Pattern.Config


{-| The default configuration.

    patternConfig : Chart.Pattern.Config
    patternConfig =
      Chart.Pattern.default

-}
default : Config
default =
  Internal.Pattern.default


{-| Edit the stripes. Pass the width of the colored part, then
the width of the white part.

    patternConfig : Chart.Pattern.Config
    patternConfig =
      Chart.Pattern.custom 5 2


-}
custom : Int -> Int -> Config
custom =
  Internal.Pattern.custom
