module Chart.Outliers exposing (Config, DotConfig, default, custom, range)


{-|

@docs Config, DotConfig, default, custom, range

-}


import Color
import Internal.Outliers as Outliers
import Internal.Dot as Dot
import Internal.Coordinate
import Chart.Coordinate as Coordinate


{-| -}
type alias Config data =
  Outliers.Config data


{-| -}
type alias DotConfig =
  { shape : Dot.Shape
  , style : Dot.Style
  , color : Color.Color -> Color.Color
  }


{-| -}
default : Config data
default =
  Outliers.default


{-| -}
custom : (List data -> data -> Bool) -> DotConfig -> Config data
custom =
  Outliers.custom



-- HELPERS


{-| -}
range : (data -> Float) -> List data -> Coordinate.Range
range =
   Internal.Coordinate.range


