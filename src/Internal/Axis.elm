module Internal.Axis exposing
  ( Config, default, custom, full, time, picky
  , variable, range, ticks, title, unit
  , viewHorizontal, viewVertical
  )


import Svg
import Svg.Attributes
import Internal.Coordinate as Coordinate exposing (..)
import Internal.Unit as Unit
import Internal.Colors as Colors
import Internal.Point as Point
import Internal.Axis.Range as Range
import Internal.Axis.Tick as Tick
import Internal.Axis.Values as Values
import Internal.Axis.Ticks as Ticks
import Internal.Axis.Line as AxisLine
import Internal.Axis.Intersection as Intersection
import Internal.Axis.Title as Title
import Internal.Svg as Svg
import Color.Convert


{-| -}
type Config value data msg =
  Config (Properties value data msg)


{-| -}
type alias Properties value data msg =
  { title : Title.Config msg
  , unit : Unit.Config
  , variable : data -> value
  , range : Range.Config
  , axisLine : AxisLine.Config msg
  , ticks : Ticks.Config msg
  }


{-| -}
default : String -> Unit.Config -> (data -> value) -> Config value data msg
default title unit variable =
  custom
    { title = Title.atDataMax 0 0 title
    , unit = unit
    , variable = variable
    , range = Range.padded 20 20
    , axisLine = AxisLine.rangeFrame Colors.gray
    , ticks = Ticks.defaultFloat
    }



{-| -}
full : String -> Unit.Config -> (data -> value) -> Config value data msg
full title unit variable =
  custom
    { title = Title.atAxisMax 0 0 title
    , unit = unit
    , variable = variable
    , range = Range.padded 20 20
    , axisLine = AxisLine.default
    , ticks = Ticks.full
    }


{-| -}
time : String -> Unit.Config -> (data -> value) -> Config value data msg
time title unit variable =
  custom
    { title = Title.atDataMax 0 0 title
    , unit = unit
    , variable = variable
    , range = Range.padded 20 20
    , axisLine = AxisLine.rangeFrame Colors.gray
    , ticks = Ticks.defaultTime
    }


{-| -}
picky :  String -> Unit.Config -> (data -> value) -> List Float -> Config value data msg
picky title unit variable ticks =
  custom
    { title = Title.atAxisMax 0 0 title
    , unit = unit
    , variable = variable
    , range = Range.padded 20 20
    , axisLine = AxisLine.default
    , ticks = 
        Ticks.custom <| \_ _ _ ->
         [ Ticks.set Tick.float toString identity ticks ]
    }


{-| -}
custom : Properties value data msg -> Config value data msg
custom =
  Config


{-| -}
variable : Config value data msg -> (data -> value)
variable (Config config) =
  config.variable


{-| -}
range : Config value data msg -> Range.Config
range (Config config) =
  config.range


{-| -}
ticks : Config value data msg -> Ticks.Config msg
ticks (Config config) =
  config.ticks


{-| -}
title : Config value data msg -> String
title (Config config) =
  let title = Title.config config.title in
  title.text


{-| -}
unit : Config value data msg -> Float -> String
unit (Config config) =
  Unit.view config.unit



-- INTERNAL / VIEW


type alias ViewConfig msg =
  { line : AxisLine.Properties msg
  , ticks : List (Ticks.Compiled msg)
  , intersection : Float
  , title : Title.Properties msg
  }


{-| -}
viewHorizontal : Coordinate.System -> Int -> Intersection.Config -> Config Float data msg -> Svg.Svg msg
viewHorizontal system pixels intersection (Config config) =
    let viewConfig =
          { line = AxisLine.config config.axisLine system.xData system.x
          , ticks = Ticks.ticks pixels system.xData system.x config.ticks
          , intersection = Intersection.getY intersection system
          , title = Title.config config.title
          }

        at x =
          { x = x, y = viewConfig.intersection }

        viewTick tick =
          viewHorizontalTick (at tick.position) tick system
    in
    Svg.c "axis--horizontal" []
      [ viewHorizontalTitle at viewConfig system
      , viewHorizontalAxisLine viewConfig.intersection viewConfig.line system
      , Svg.c "ticks" [] (List.map viewTick viewConfig.ticks)
      ]


{-| -}
viewVertical : Coordinate.System -> Int -> Intersection.Config -> Config value data msg -> Svg.Svg msg
viewVertical system pixels intersection (Config config) =
    let viewConfig =
          { line = AxisLine.config config.axisLine system.yData system.y
          , ticks = Ticks.ticks pixels system.yData system.y config.ticks
          , intersection = Intersection.getX intersection system
          , title = Title.config config.title
          }

        at y =
          { x = viewConfig.intersection, y = y }

        viewTick tick =
          viewVerticalTick (at tick.position) tick system
    in
    Svg.c "axis--vertical" []
      [ viewVerticalTitle at viewConfig system
      , viewVerticalAxisLine viewConfig.intersection viewConfig.line system 
      , Svg.c "ticks" [] (List.map viewTick viewConfig.ticks)
      ]



-- INTERNAL / VIEW / TITLE


viewHorizontalTitle : (Float -> Coordinate.Point) -> ViewConfig msg -> Coordinate.System -> Svg.Svg msg
viewHorizontalTitle at { title } system =
  let position = at (title.position system.xData system.x)
      ( xOffset, yOffset ) = title.offset
  in
  Svg.c "title" 
    [ Svg.transform [ Svg.move position.x position.y system, Svg.offset (xOffset + 15) (yOffset + 5) ]
    , Svg.anchor (Maybe.withDefault Svg.Start title.anchor)
    ]
    [ title.view title.text ]


viewVerticalTitle : (Float -> Coordinate.Point) -> ViewConfig msg -> Coordinate.System -> Svg.Svg msg
viewVerticalTitle at { title } system =
  let position = at (title.position system.yData system.y)
      ( xOffset, yOffset ) = title.offset
  in
  Svg.c "title"
    [ Svg.transform [ Svg.move position.x position.y system, Svg.offset (xOffset + 2) (yOffset - 10) ]
    , Svg.anchor (Maybe.withDefault Svg.End title.anchor)
    ]
    [ title.view title.text ]



-- INTERNAL / VIEW / LINE


viewHorizontalAxisLine : Float -> AxisLine.Properties msg -> Coordinate.System -> Svg.Svg msg
viewHorizontalAxisLine axisPosition config system =
  Svg.horizontal (attributesLine config system) axisPosition config.start config.end system


viewVerticalAxisLine : Float -> AxisLine.Properties msg -> Coordinate.System -> Svg.Svg msg
viewVerticalAxisLine axisPosition config system =
  Svg.vertical (attributesLine config system) axisPosition config.start config.end system


attributesLine :AxisLine.Properties msg -> Coordinate.System -> List (Svg.Attribute msg)
attributesLine { events, width, color } system =
  events ++
    [ Svg.Attributes.strokeWidth (toString width)
    , Svg.Attributes.stroke (Color.Convert.colorToCssRgba color)
    , Svg.withinChartArea system
    ]



-- INTERNAL / VIEW / TICK


viewHorizontalTick : Coordinate.Point -> Ticks.Compiled msg -> Coordinate.System -> Svg.Svg msg
viewHorizontalTick ({ x, y } as coordinates) tick system =
  Svg.c "tick" []
    [ Svg.xTick (lengthOfTick tick.config) (attributesTick tick.config) y x system
    , viewHorizontalLabel tick.config coordinates (tick.config.label tick.label) system
    ]


viewVerticalTick : Coordinate.Point -> Ticks.Compiled msg -> Coordinate.System -> Svg.Svg msg
viewVerticalTick ({ x, y } as coordinates) tick system =
  Svg.c "tick" []
    [ Svg.yTick (lengthOfTick tick.config) (attributesTick tick.config) x y system
    , viewVerticalLabel tick.config coordinates (tick.config.label tick.label) system
    ]


lengthOfTick : Tick.Properties msg -> Float
lengthOfTick { length, direction } =
  if Tick.isPositive direction then -length else length


attributesTick : Tick.Properties msg -> List (Svg.Attribute msg)
attributesTick { width, color } =
  [ Svg.Attributes.strokeWidth (toString width)
  , Svg.Attributes.stroke (Color.Convert.colorToCssRgba color) 
  ]


viewHorizontalLabel : Tick.Properties msg -> Coordinate.Point -> Svg.Svg msg -> Coordinate.System -> Svg.Svg msg
viewHorizontalLabel { direction, length } position view system =
  let yOffset = if Tick.isPositive direction then -5 - length else 15 + length
  in
  Svg.c "tick__label"
    [ Svg.transform [ Svg.move position.x position.y system, Svg.offset 0 yOffset ]
    , Svg.anchor Svg.Middle
    ]
    [ view ]


viewVerticalLabel : Tick.Properties msg -> Coordinate.Point -> Svg.Svg msg -> Coordinate.System -> Svg.Svg msg
viewVerticalLabel { direction, length } position view system =
  let anchor = if Tick.isPositive direction then Svg.Start else Svg.End
      xOffset = if Tick.isPositive direction then 5 + length else -5 - length
  in
  Svg.c "tick__label" 
    [ Svg.transform [ Svg.move position.x position.y system, Svg.offset xOffset 5 ]
    , Svg.anchor anchor
    ]
    [ view ]
