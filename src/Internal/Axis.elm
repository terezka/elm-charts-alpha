module Internal.Axis exposing
  ( Config, default, custom, full, time, none, picky
  , variable, pixels, range, ticks, title
  , viewHorizontal, viewVertical
  )


import Svg exposing (Svg, Attribute, g, text_, tspan, text)
import Svg.Attributes as Attributes exposing (class, strokeWidth, stroke)
import Internal.Coordinate as Coordinate exposing (..)
import Internal.Colors as Colors
import Internal.Data as Data
import Internal.Axis.Range as Range
import Internal.Axis.Tick as Tick
import Internal.Axis.Values as Values
import Internal.Axis.Ticks as Ticks
import Internal.Axis.Line as AxisLine
import Internal.Axis.Intersection as Intersection
import Internal.Axis.Title as Title
import Internal.Svg as Svg exposing (..)
import Color.Convert


{-| -}
type Config value data msg =
  Config (Properties value data msg)


{-| -}
type alias Properties value data msg =
  { title : Title.Config msg
  , unit : String
  , variable : data -> value
  , pixels : Int
  , range : Range.Config
  , axisLine : AxisLine.Config msg
  , ticks : Ticks.Config msg
  }


{-| -}
default : Int -> String -> String -> (data -> value) -> Config value data msg
default pixels title unit variable =
  custom
    { title = Title.atDataMax 0 0 title
    , unit = unit
    , variable = variable
    , pixels = pixels
    , range = Range.padded 20 20
    , axisLine = AxisLine.rangeFrame Colors.gray
    , ticks =
        Ticks.custom <| \data range ->
          let smallest = Coordinate.smallestRange data range
              rangeLong = range.max - range.min
              rangeSmall = smallest.max - smallest.min
              diff = 1 - (rangeLong - rangeSmall) / rangeLong
              amount = round <| diff * toFloat pixels / 90
              values = Values.float (Values.around amount) smallest
          in
          [ Ticks.set Tick.float toString identity values ]
    }



{-| -}
full : Int -> String -> String -> (data -> value) -> Config value data msg
full pixels title unit variable =
  custom
    { title = Title.atAxisMax 0 0 title
    , unit = unit
    , variable = variable
    , pixels = pixels
    , range = Range.padded 20 20
    , axisLine = AxisLine.default
    , ticks =
        Ticks.custom <| \data range ->
          let largest = Coordinate.largestRange data range
              amount = pixels // 90
              values = Values.float (Values.around amount) largest
          in
          [ Ticks.set Tick.float toString identity values ]
    }


{-| -}
time : Int -> String -> String -> (data -> value) -> Config value data msg
time pixels title unit variable =
  custom
    { title = Title.atDataMax 0 0 title
    , unit = unit
    , variable = variable
    , pixels = pixels
    , range = Range.padded 20 20
    , axisLine = AxisLine.rangeFrame Colors.gray
    , ticks =
        Ticks.custom <| \data range ->
          let smallest = Coordinate.smallestRange data range
              rangeLong = range.max - range.min
              rangeSmall = smallest.max - smallest.min
              diff = 1 - (rangeLong - rangeSmall) / rangeLong
              amount = round <| diff * toFloat pixels / 90
              values = Values.time amount smallest
          in
          [ Ticks.set Tick.time Tick.format .timestamp values ]
    }


{-| -} -- TODO should this exist??
none : Int -> String -> (data -> value) ->  Config value data msg
none pixels unit variable =
  custom
    { title = Title.default ""
    , unit = unit
    , variable = variable
    , pixels = pixels
    , range = Range.padded 20 20
    , axisLine = AxisLine.none
    , ticks = Ticks.custom <| \_ _ -> []
    }


{-| -}
picky : Int -> String -> String -> (data -> value) -> List Float -> Config value data msg
picky pixels title unit variable ticks =
  custom
    { title = Title.atAxisMax 0 0 title
    , unit = unit
    , variable = variable
    , pixels = pixels
    , range = Range.padded 20 20
    , axisLine = AxisLine.default
    , ticks = Ticks.custom <| \_ _ -> [ Ticks.set Tick.float toString identity ticks ]
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
pixels : Config value data msg -> Float
pixels (Config config) =
  toFloat config.pixels


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
  let { title } = Title.config config.title in
  title



-- INTERNAL / VIEW


type alias ViewConfig msg =
  { line : AxisLine.Properties msg
  , ticks : List (Ticks.Compiled msg)
  , intersection : Float
  , title : Title.Properties msg
  }


{-| -}
viewHorizontal : Coordinate.System -> Intersection.Config -> Config Float data msg -> Svg msg
viewHorizontal system intersection (Config config) =
    let
        viewConfig =
          { line = AxisLine.config config.axisLine system.xData system.x
          , ticks = Ticks.ticks system.xData system.x config.ticks
          , intersection = Intersection.getY intersection system
          , title = Title.config config.title
          }

        at x =
          { x = x, y = viewConfig.intersection }

        viewAxisLine =
          viewHorizontalAxisLine system viewConfig.intersection

        viewTick tick =
          viewHorizontalTick system (at tick.position) tick
    in
    g [ class "chart__axis--horizontal" ]
      [ viewHorizontalTitle system at viewConfig
      , viewAxisLine viewConfig.line
      , g [ class "chart__ticks" ] (List.map viewTick viewConfig.ticks)
      ]


{-| -}
viewVertical : Coordinate.System -> Intersection.Config -> Config value data msg -> Svg msg
viewVertical system intersection (Config config) =
    let
        viewConfig =
          { line = AxisLine.config config.axisLine system.yData system.y
          , ticks = Ticks.ticks system.yData system.y config.ticks
          , intersection = Intersection.getX intersection system
          , title = Title.config config.title
          }

        at y =
          { x = viewConfig.intersection, y = y }

        viewAxisLine =
          viewVerticalAxisLine system viewConfig.intersection

        viewTick tick =
          viewVerticalTick system (at tick.position) tick
    in
    g [ class "chart__axis--vertical" ]
      [ viewVerticalTitle system at viewConfig
      , viewAxisLine viewConfig.line
      , g [ class "chart__ticks" ] (List.map viewTick viewConfig.ticks)
      ]



-- INTERNAL / VIEW / TITLE


viewHorizontalTitle : Coordinate.System -> (Float -> Data.Point) -> ViewConfig msg -> Svg msg
viewHorizontalTitle system at { title } =
  let position = at (title.position system.xData system.x)
      ( xOffset, yOffset ) = title.offset
  in
  g [ class "chart__title"
    , transform
        [ move system position.x position.y
        , offset (xOffset + 15) (yOffset + 5)
        ]
    , anchorStyle (Maybe.withDefault Start title.anchor)
    ]
    [ title.view title.title ]


viewVerticalTitle : Coordinate.System -> (Float -> Data.Point) -> ViewConfig msg -> Svg msg
viewVerticalTitle system at { title } =
  let position = at (title.position system.yData system.y)
      ( xOffset, yOffset ) = title.offset
  in
  g [ class "chart__title"
    , transform
        [ move system position.x position.y
        , offset (xOffset + 2) (yOffset - 10)
        ]
    , anchorStyle (Maybe.withDefault End title.anchor)
    ]
    [ title.view title.title ]



-- INTERNAL / VIEW / LINE


viewHorizontalAxisLine : Coordinate.System -> Float -> AxisLine.Properties msg -> Svg msg
viewHorizontalAxisLine system axisPosition config =
  horizontal system (attributesLine system config) axisPosition config.start config.end


viewVerticalAxisLine : Coordinate.System -> Float -> AxisLine.Properties msg -> Svg msg
viewVerticalAxisLine system axisPosition config =
  vertical system (attributesLine system config) axisPosition config.start config.end


attributesLine : Coordinate.System -> AxisLine.Properties msg -> List (Svg.Attribute msg)
attributesLine system { events, width, color } =
  events ++
    [ strokeWidth (toString width)
    , stroke (Color.Convert.colorToCssRgba color)
    , Svg.withinChartArea system
    ]



-- INTERNAL / VIEW / TICK


viewHorizontalTick : Coordinate.System -> Data.Point -> Ticks.Compiled msg -> Svg msg
viewHorizontalTick system ({ x, y } as point) tick =
  g [ class "chart__tick" ]
    [ xTick system (lengthOfTick tick.config) (attributesTick tick.config) y x
    , viewHorizontalLabel system tick.config point (tick.config.label tick.label)
    ]


viewVerticalTick : Coordinate.System -> Data.Point -> Ticks.Compiled msg -> Svg msg
viewVerticalTick system ({ x, y } as point) tick =
  g [ class "chart__tick" ]
    [ yTick system (lengthOfTick tick.config) (attributesTick tick.config) x y
    , viewVerticalLabel system tick.config point (tick.config.label tick.label)
    ]


lengthOfTick : Tick.Properties msg -> Float
lengthOfTick { length, direction } =
  if Tick.isPositive direction then -length else length


attributesTick : Tick.Properties msg -> List (Svg.Attribute msg)
attributesTick { width, color } =
  [ strokeWidth (toString width), stroke (Color.Convert.colorToCssRgba color) ]


viewHorizontalLabel : Coordinate.System -> Tick.Properties msg -> Data.Point -> Svg msg -> Svg msg
viewHorizontalLabel system { direction, length } position view =
  let
    yOffset = if Tick.isPositive direction then -5 - length else 15 + length
  in
  g [ transform [ move system position.x position.y, offset 0 yOffset ]
    , anchorStyle Middle
    ]
    [ view ]


viewVerticalLabel : Coordinate.System -> Tick.Properties msg -> Data.Point -> Svg msg -> Svg msg
viewVerticalLabel system { direction, length } position view =
  let
    anchor = if Tick.isPositive direction then Start else End
    xOffset = if Tick.isPositive direction then 5 + length else -5 - length
  in
  g [ transform [ move system position.x position.y, offset xOffset 5 ]
    , anchorStyle anchor
    ]
    [ view ]
