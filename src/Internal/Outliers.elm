module Internal.Outliers
  exposing
    ( Config
    , DotConfig
    , default
    , custom
    , isOutlier
    , dotConfig
    , basic
    )


import Color.Manipulate
import Internal.Dot as Dots
import Color.Manipulate


{-| -}
type Config data =
  Config (List data -> data -> Bool) DotConfig


{-| -}
type alias DotConfig =
  Dots.Outlier


{-| -}
default : Config data
default =
  Config (\_ _ -> False)
    { shape = Dots.Cross
    , style = Dots.full 3
    , color = Color.Manipulate.lighten 0.5
    }


{-| -}
custom : (List data -> data -> Bool) -> DotConfig -> Config data
custom =
  Config


{-| -}
basic : DotConfig
basic =
  { shape = Dots.Cross
  , style = Dots.full 3
  , color = Color.Manipulate.lighten 0.5
  }


-- INTERNAL


{-| -}
isOutlier : Config data -> List data -> (data -> Bool)
isOutlier (Config func _) =
  func


{-| -}
dotConfig : Config data -> DotConfig
dotConfig (Config _ config) =
  config
