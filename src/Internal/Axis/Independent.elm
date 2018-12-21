module Internal.Axis.Independent exposing
  ( Config, Properties, default, custom
  -- INTERNAL
  , title, label
  , toNormal
  )


import Internal.Axis.Tick as Tick
import Internal.Axis.Ticks as Ticks
import Internal.Axis.Range as Range
import Internal.Axis.Line as AxisLine
import Internal.Axis.Title as Title
import Internal.Axis as Axis
import Internal.Unit as Unit
import Internal.Colors as Colors
import Internal.Svg as Svg
import Internal.Utils as Utils



{-| -}
type Config data msg =
  Config (Properties data msg)


{-| -}
type alias Properties data msg =
  { title : Title.Config msg
  , range : Range.Config
  , line : AxisLine.Config msg
  , label : data -> String
  , tick : Tick.Config msg
  }


{-| -}
default : String -> (data -> String) -> Config data msg
default title_ label_ =
  custom
    { title = Title.default title_
    , range = Range.default
    , line = AxisLine.default
    , label = label_
    , tick = Tick.float
    }


{-| -}
custom : Properties data msg -> Config data msg
custom =
  Config



-- INTERNAL / API


{-| -}
title : Config data msg -> String
title (Config config) =
  let title_ = Title.config config.title in
  title_.text


{-| -}
label : Config data msg -> data -> String
label (Config config) =
  config.label



-- INTERNAL / CONVERT TO NORMAL AXIS


{-| -}
toNormal : Config data msg -> List data -> Axis.Config Float data msg
toNormal (Config config) data =
  let variable datum =
        Maybe.withDefault 1 (Utils.findIndex datum data)

      indexTicks =
        Ticks.custom <| \_ _ _ ->
          let position = Tuple.first >> Utils.add 1 >> toFloat
              label_ = Tuple.second >> config.label
              indexedData = List.indexedMap Tuple.pair data
          in
          [ Ticks.set config.tick label_ position indexedData ]
  in
  Axis.custom
    { title = config.title
    , unit = Unit.none
    , variable = variable >> toFloat
    , range = config.range
    , line = config.line
    , ticks = indexTicks
    }


