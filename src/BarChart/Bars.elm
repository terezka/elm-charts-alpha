module BarChart.Bars exposing (Config, default, custom)

{-| @docs Config, default, custom -}


import Internal.Bars


{-| -}
type alias Config =
  Internal.Bars.Config


{-| -}
default : Config
default =
  Internal.Bars.default


{-| -}
custom : Int -> Float -> Config
custom =
  Internal.Bars.custom


