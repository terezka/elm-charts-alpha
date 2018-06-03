module ScatterChart.Trend
  exposing
    ( Config
    , default
    , single
    , singleCustom
    , individual
    , individualCustom
    --
    , Function
    , linear
    )


import Internal.Trend as Trend
import Color


{-| -}
type alias Config data =
  Trend.Config data


{-| -}
default : Config data
default =
  Trend.default


{-| -}
single : Color.Color -> Config data
single =
  Trend.single


{-| -}
singleCustom :
  { color : Color.Color
  , width : List data -> Float
  , function : Function
  , includeOutliers : Bool
  }
  -> Config data
singleCustom { color, width, function, includeOutliers } =
  Trend.singleCustom color width function includeOutliers


{-| -}
individual : Config data
individual =
  Trend.individual


{-| -}
individualCustom :
  { color : Color.Color -> Color.Color
  , width : List data -> Float
  , function : Function
  , includeOutliers : Bool
  }
  -> Config data
individualCustom { color, width, function, includeOutliers } =
  Trend.individualCustom color width function includeOutliers



-- FUNCTIONS


{-| -}
type alias Function =
  List ( Float, Float ) -> Float -> Float


{-| -}
linear : Function
linear =
  Trend.linear


