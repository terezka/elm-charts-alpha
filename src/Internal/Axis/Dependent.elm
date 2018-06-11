module Internal.Axis.Dependent exposing
  ( Config, Properties, default, custom
  -- INTERNAL
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



{-| -}
type Config msg =
  Config (Properties msg)


{-| -}
type alias Properties msg =
  { title : Title.Config msg
  , pixels : Int
  , range : Range.Config
  , axisLine : AxisLine.Config msg
  , ticks : Ticks.Config msg
  }


{-| -}
default : Int -> String -> Config msg
default pixels title =
  custom
    { title = Title.default title
    , range = Range.default
    , pixels = pixels
    , axisLine = AxisLine.default
    , ticks = -- TODO weird oppisite axis length ticks discrepancy
        Ticks.custom <| \data range ->
          let smallest = Coordinate.smallestRange data range
              rangeLong = range.max - range.min
              rangeSmall = smallest.max - smallest.min
              diff = 1 - (rangeLong - rangeSmall) / rangeLong
              amount = round <| diff * toFloat pixels / 90
          in
          List.map Tick.float <| Values.float (Values.around amount) smallest
    }


{-| -}
custom : Properties msg -> Config msg
custom =
  Config


toNormal : Config msg -> Axis.Config Float data msg
toNormal (Config config) =
  Axis.custom
    { title = config.title
    , variable = \_ -> 0 -- not used
    , pixels = config.pixels
    , range = config.range
    , axisLine = config.axisLine
    , ticks = config.ticks
    }
