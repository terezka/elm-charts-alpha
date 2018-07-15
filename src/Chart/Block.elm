module Chart.Block exposing (Config, default, custom)

{-| 

@docs Config, default, custom 

-}


import Internal.Block


{-| -}
type alias Config =
  Internal.Block.Config


{-| -}
default : Config
default =
  Internal.Block.default


{-| -}
custom : Int -> Float -> Config
custom =
  Internal.Block.custom


