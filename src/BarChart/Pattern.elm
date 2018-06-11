module BarChart.Pattern exposing (Config, default, custom)


{-| -}

import Internal.Pattern


{-| -}
type alias Config =
    Internal.Pattern.Config


{-| -}
default : Config
default =
  Internal.Pattern.default


{-| -}
custom : Int -> Int -> Config
custom =
  Internal.Pattern.custom
