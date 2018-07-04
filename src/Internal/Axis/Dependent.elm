module Internal.Axis.Dependent exposing
  ( Config, Properties, default, custom
  -- INTERNAL
  , unit, title
  , toNormal
  )


import Internal.Coordinate as Coordinate
import Internal.Axis.Tick as Tick
import Internal.Axis.Values as Values
import Internal.Axis.Ticks as Ticks
import Internal.Axis.Range as Range
import Internal.Axis.Line as AxisLine
import Internal.Axis.Title as Title
import Internal.Axis as Axis
import Internal.Unit as Unit
import Internal.Utils as Utils



{-| -}
type Config msg =
  Config (Properties msg)


{-| -}
type alias Properties msg =
  { title : Title.Config msg
  , unit : Unit.Config
  , pixels : Int
  , range : Range.Config
  , axisLine : AxisLine.Config msg
  , ticks : Ticks.Config msg
  }


{-| -}
default : Int -> String -> Unit.Config -> Config msg
default pixels title unit =
  custom
    { title = Title.default title
    , unit = unit
    , range = Range.default
    , pixels = pixels
    , axisLine = AxisLine.default
    , ticks = Ticks.defaultFloat
    }


{-| -}
custom : Properties msg -> Config msg
custom =
  Config



-- INTERNAL / API


{-| -}
unit : Config msg -> Float -> String
unit (Config properties) =
  Unit.view properties.unit


{-| -}
title : Config msg -> String
title (Config config) =
  let title = Title.config config.title in
  title.text



-- INTERNAL / CONVERT TO NORMAL AXIS


{-| -}
toNormal : Config msg -> List data -> Axis.Config Float data msg
toNormal (Config config) data =
  let variable datum =
        Maybe.withDefault 1 (Utils.findIndex datum data)
  in
  Axis.custom
    { title = config.title
    , unit = config.unit
    , variable = variable >> toFloat
    , pixels = config.pixels
    , range = config.range
    , axisLine = config.axisLine
    , ticks = config.ticks
    }


