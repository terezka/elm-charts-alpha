module Internal.Axis.Independent exposing
  ( Config, Properties, default, custom
  -- INTERNAL
  , toNormal, tick, config
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
  , label : data -> String
  , tick : Tick.Config msg
  }


{-| -}
default : Int -> String -> (data -> String) -> Config data msg
default pixels title label =
  custom
    { title = Title.default title
    , range = Range.default
    , pixels = pixels
    , axisLine = AxisLine.default
    , label = label
    , tick = defaultTick
    }


{-| -}
custom : Properties data msg -> Config data msg
custom =
  Config


{-| -}
config : Config data msg -> Properties data msg
config (Config properties) =
  properties


{-| -}
tick : Config data msg -> Tick.Config msg
tick (Config config) =
  config.tick


toNormal : List data -> Config data msg -> Axis.Config Float data msg
toNormal data (Config config) =
  let
    find datum =
      List.filterMap (isOk datum)
        >> List.head >> Maybe.withDefault 0 >> (+) 1 >> toFloat

    isOk datum ( i, v ) =
      if datum == v then Just i else Nothing
  in
  Axis.custom
    { title = config.title
    , unit = ""
    , variable = \datum -> find datum (List.indexedMap (,) data)
    , pixels = config.pixels
    , range = config.range
    , axisLine = config.axisLine
    , ticks =
        Ticks.custom <| \_ _ ->
          let position = Tuple.first >> (+) 1 >> toFloat
              label = Tuple.second >> config.label
          in
          [ Ticks.set config.tick label position (List.indexedMap (,) data) ]
    }


defaultTick : Tick.Config msg
defaultTick =
  Tick.custom
    { color = Colors.gray
    , width = 1
    , length = 5
    , grid = True
    , direction = Tick.Negative
    , label = Svg.label "inherit"
    }
