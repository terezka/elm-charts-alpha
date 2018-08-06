module Chart.Block exposing (Config, default, custom)

{-| 

# WARNING! THIS IS AN ALPHA VERSION

*IT HAS MISSING, MISLEADING AND PLAIN WRONG DOCUMENTATION.*
*IT HAS BUGS AND AWKWARDNESS.*
*USE AT OWN RISK.*

This configured general traits of all your blocks.

@docs Config, default, custom 

-}


import Internal.Block


{-| Use in the `Chart.Blocks.Config` passed to `Chart.Blocks.viewCustom`.

    chartConfig : Chart.Config value data msg
    chartConfig =
      { ...
      , block = Chart.Block.default
      , ...
      }

-}
type alias Config =
  Internal.Block.Config


{-| -}
default : Config
default =
  Internal.Block.default


{-| Customize your blocks. Pass the border radius and the max width.

    blockConfig : Chart.Block.Config
    blockConfig =
      Chart.Block.custom 2 50


_Note:_ Be aware that changing the width can meddle with how the
numbers in your chart are perceived, as people commonly evaluate
base of the _area_ of the block, rather than only the height. 

-}
custom : Int -> Float -> Config
custom =
  Internal.Block.custom


