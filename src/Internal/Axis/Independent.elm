module Internal.Axis.Independent exposing
  ( Config, Properties, default, custom
  -- INTERNAL
  , toNormal
  )


import Internal.Axis.Tick as Tick
import Internal.Axis.Ticks as Ticks
import Internal.Axis.Range as Range
import Internal.Axis.Line as AxisLine
import Internal.Axis.Title as Title
import Internal.Axis as Axis
import Internal.Colors as Colors
import Internal.Svg as Svg



{-| -}
type Config data msg =
  Config (Properties data msg)


{-| -}
type alias Properties data msg =
  { title : Title.Config msg
  , pixels : Int
  , range : Range.Config
  , axisLine : AxisLine.Config msg
  , tick : Int -> data -> Tick.Config msg
  }


{-| -}
default : Int -> String -> (data -> String) -> Config data msg
default pixels title label =
  custom
    { title = Title.default title
    , range = Range.default
    , pixels = pixels
    , axisLine = AxisLine.default
    , tick = defaultTick label
    }


{-| -}
custom : Properties data msg -> Config data msg
custom =
  Config


toNormal : List data -> Config data msg -> Axis.Config Float data msg
toNormal data (Config config) =
  Axis.custom
    { title = config.title
    , variable = \_ -> 0 -- not used
    , pixels = config.pixels
    , range = config.range
    , axisLine = config.axisLine
    , ticks =
        Ticks.custom <| \_ _ ->
          let indexes = List.range 1 (List.length data) in
          List.map2 config.tick indexes data
    }


defaultTick : (data -> String) -> Int -> data -> Tick.Config msg
defaultTick label n data =
  Tick.custom
    { position = toFloat n
    , color = Colors.gray
    , width = 1
    , length = 5
    , grid = True
    , direction = Tick.Negative
    , label = Just (Svg.label "inherit" (label data))
    }
