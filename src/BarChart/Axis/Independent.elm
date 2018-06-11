module BarChart.Axis.Independent exposing
  ( Config, default, custom
  )


import Internal.Axis.Independent as Independent
import Internal.Axis.Tick as Tick
import Internal.Axis.Line as AxisLine
import Internal.Axis.Title as Title
import Internal.Axis.Range as Range


{-| -}
type alias Config data msg =
  Independent.Config data msg


{-| -}
default : Int -> String -> (data -> String) -> Config data msg
default =
  Independent.default


{-| -}
custom : Properties data msg -> Config data msg
custom =
  Independent.custom


{-| -}
type alias Properties data msg =
  { title : Title.Config msg
  , pixels : Int
  , range : Range.Config
  , axisLine : AxisLine.Config msg
  , tick : Int -> data -> Tick.Config msg
  }