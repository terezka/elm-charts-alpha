module BarChart.Axis.Dependent exposing
  ( Config, default, custom
  )


import Internal.Axis.Dependent as Dependent
import Internal.Axis.Ticks as Ticks
import Internal.Axis.Line as AxisLine
import Internal.Axis.Title as Title
import Internal.Axis.Range as Range


{-| -}
type alias Config msg =
  Dependent.Config msg


{-| -}
default : Int -> String -> Config msg
default =
  Dependent.default


{-| -}
custom : Properties msg -> Config msg
custom =
  Dependent.custom


{-| -}
type alias Properties msg =
  { title : Title.Config msg
  , pixels : Int
  , range : Range.Config
  , axisLine : AxisLine.Config msg
  , ticks : Ticks.Config msg
  }

