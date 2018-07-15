module Chart.Pattern exposing (Config, default, custom)


{-| This configures the striped pattern of the block, if patterned.
See `Chart.Blocks.series` on how to make a block patterned.

@docs Config, default, custom

-}

import Internal.Pattern


{-| -}
type alias Config =
    Internal.Pattern.Config


{-| The default configuration.

    Chart.Blocks.viewCustom
      { ...
      , pattern = Chart.Pattern.default
      , ...
      }

-}
default : Config
default =
  Internal.Pattern.default


{-| Edit the stripes. Pass the width of the colored part, then
the width of the white part.

    Chart.Blocks.viewCustom
      { ...
      , pattern = Chart.Pattern.custom 5 2
      , ...
      }

-}
custom : Int -> Int -> Config
custom =
  Internal.Pattern.custom
