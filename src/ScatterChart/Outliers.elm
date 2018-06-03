module ScatterChart.Outliers
  exposing
    ( Config
    , DotConfig
    , default
    , custom
    , range
    )


import Color
import Internal.Outliers as Outliers
import Internal.Dots as Dots
import Internal.Coordinate
import ScatterChart.Coordinate as Coordinate


{-| -}
type alias Config data =
  Outliers.Config data


{-| -}
type alias DotConfig =
  { shape : Dots.Shape
  , style : Dots.Style
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


