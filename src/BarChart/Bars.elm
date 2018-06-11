module BarChart.Bars exposing (Config, default, custom, Properties, Label)

{-| @docs Config, default, custom, Properties -}


import Internal.Bars
import Svg


{-| -}
type alias Config msg =
  Internal.Bars.Config msg


{-| -}
default : Config msg
default =
  Internal.Bars.default


{-| -}
custom : Properties msg -> Config msg
custom =
  Internal.Bars.custom


{-| -}
type alias Properties msg =
  { label : Maybe (Float -> Label msg)
  , width : Float
  , borderRadius : Int
  }


{-| -}
type alias Label msg =
  { attributes : List (Svg.Attribute msg)
  , xOffset : Float
  , yOffset : Float
  , text : String
  }
