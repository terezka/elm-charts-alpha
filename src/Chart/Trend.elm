module Chart.Trend
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


{-|

@docs Config, default, single, singleCustom, individual, individualCustom

@docs Function, linear

-}


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
  }
  -> Config data
singleCustom { color, width, function } =
  Trend.singleCustom color width function


{-| -}
individual : Config data
individual =
  Trend.individual


{-| -}
individualCustom :
  { color : Color.Color -> Color.Color
  , width : List data -> Float
  , function : Function
  }
  -> Config data
individualCustom { color, width, function } =
  Trend.individualCustom color width function



-- FUNCTIONS


{-| -}
type alias Function =
  List ( Float, Float ) -> Float -> Float


{-| -}
linear : Function
linear =
  Trend.linear


