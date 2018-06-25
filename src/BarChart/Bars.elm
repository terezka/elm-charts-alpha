module BarChart.Bars exposing (Config, default, custom, Properties, Label)

{-| @docs Config, default, custom, Properties -}


import Internal.Bars


{-| -}
type alias Config =
  Internal.Bars.Config


{-| -}
default : Config
default =
  Internal.Bars.default


{-| -}
custom : Properties -> Config
custom =
  Internal.Bars.custom


{-| -}
type alias Properties =
  { label : Maybe (Float -> Label)
  , width : Float
  , borderRadius : Int
  }


{-| -}
type alias Label =
  { xOffset : Float
  , yOffset : Float
  , text : String
  }
