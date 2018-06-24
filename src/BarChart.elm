module BarChart exposing (view, Config, Bar, bar)

{-| -}

import Html
import Html.Attributes
import Svg
import Svg.Attributes
import Array

import BarChart.Junk as Junk
import BarChart.Axis.Dependent as AxisDependent
import BarChart.Axis.Independent as AxisIndependent
import BarChart.Grid as Grid
import BarChart.Events as Events
import BarChart.Legends as Legends
import BarChart.Container as Container
import BarChart.Orientation as Orientation
import BarChart.Pattern as Pattern
import BarChart.Bars as Bars

import Internal.Bars
import Internal.Orientation
import Internal.Events
import Internal.Axis
import Internal.Axis.Dependent
import Internal.Axis.Independent
import Internal.Axis.Intersection
import Internal.Axis.Range
import Internal.Junk
import Internal.Grid
import Internal.Container
import Internal.Pattern
import Internal.Legends

import Internal.Colors as Colors
import Internal.Data as Data
import Internal.Utils as Utils
import Internal.Coordinate as Coordinate
import Internal.Svg as Svg
import Color


{-| -}
type alias Config data msg =
  { independentAxis : AxisIndependent.Config data msg
  , dependentAxis : AxisDependent.Config msg
  , container : Container.Config msg
  , orientation : Orientation.Config
  , legends : Legends.Config msg
  , events : Events.Config data msg
  , grid : Grid.Config
  , bars : Bars.Config msg
  , junk : Junk.Config data msg
  , pattern : Pattern.Config
  }


{-| -}
type alias Bar data =
  Internal.Bars.Bar data


{-| -}
type alias Style =
  { fill : Color.Color
  , border : Color.Color
  }


{-| -}
bar :
  { title : String
  , style : { base : Style, emphasized : data -> Style }
  , variable : data -> Float
  , pattern : Bool
  }
  -> Bar data
bar =
  Internal.Bars.bar


{-| -}
view : Config data msg -> List (Bar data) -> List data -> Svg.Svg msg
view config bars data =
  let
    -- Data
    barsConfigs =
      List.map Internal.Bars.barConfig bars

    totalOfBars =
      List.length barsConfigs

    groups =
      Internal.Bars.toGroups config.orientation config.bars barsConfigs data

    -- Axes
    ( horizontalAxis, verticalAxis ) =
      case config.orientation of
        Internal.Orientation.Horizontal ->
          ( Internal.Axis.Dependent.toNormal data config.dependentAxis
          , Internal.Axis.Independent.toNormal data config.independentAxis
          )

        Internal.Orientation.Vertical ->
          ( Internal.Axis.Independent.toNormal data config.independentAxis
          , Internal.Axis.Dependent.toNormal data config.dependentAxis
          )

    -- System
    points =
      List.concatMap (List.map .point) groups

    system =
      toSystem config horizontalAxis verticalAxis data points

    dataPoints =
      toDataPoints config system bars data

    -- Junk
    addGrid =
      Internal.Junk.addBelow
        (Internal.Grid.view system
          (Internal.Axis.ticks horizontalAxis)
          (Internal.Axis.ticks verticalAxis)
          config.grid
        )

    junk =
       Internal.Junk.getLayers (junkDefaults config barsConfigs horizontalAxis verticalAxis) system config.junk
        |> addGrid

    intersection =
      Internal.Axis.Intersection.custom .min Internal.Axis.Intersection.towardsZero

    -- View
    viewGroups =
      List.map (Internal.Bars.viewGroup config.orientation config.bars system (List.length data) totalOfBars) groups

    attributes =
      List.concat
        [ Internal.Container.properties .attributesSvg config.container
        , Internal.Events.toContainerAttributes dataPoints system config.events
        , [ viewBoxAttribute system ]
        ]

    toLegend width bar =
      -- TODO color
      { sample = Svg.square width (Internal.Bars.borderRadius config.bars) bar.style.base.fill bar.style.base.border
      , label = bar.title
      }

    viewLegends =
      Internal.Legends.view
        { system = system
        , config = config.legends
        , legends = \width -> List.map (toLegend width) barsConfigs
        }
  in
  container config system junk.html <|
    Svg.svg attributes
      [ Svg.defs [] (clipPath system :: Internal.Pattern.toDefs config.pattern)
      , Svg.g [ Svg.Attributes.class "chart__junk--below" ] junk.below
      , chartAreaPlatform config dataPoints system
      , Svg.g [ Svg.Attributes.class "groups" ] viewGroups
      , Internal.Axis.viewHorizontal system intersection horizontalAxis
      , Internal.Axis.viewVertical system intersection verticalAxis
      , viewLegends
      , Svg.g [ Svg.Attributes.class "chart__junk--above" ] junk.above
      ]



-- INTERNAL


viewBoxAttribute : Coordinate.System -> Html.Attribute msg
viewBoxAttribute { frame } =
  Svg.Attributes.viewBox <|
    "0 0 " ++ toString frame.size.width ++ " " ++ toString frame.size.height


container : Config data msg -> Coordinate.System -> List (Html.Html msg) -> Html.Html msg -> Html.Html msg
container config { frame } junkHtml plot  =
  let
    userAttributes =
      Internal.Container.properties .attributesHtml config.container

    sizeStyles =
      Internal.Container.sizeStyles config.container frame.size.width frame.size.height

    styles =
      Html.Attributes.style <| ( "position", "relative" ) :: sizeStyles
  in
  Html.div (styles :: userAttributes) (plot :: junkHtml)


chartAreaAttributes : Coordinate.System -> List (Svg.Attribute msg)
chartAreaAttributes system =
  [ Svg.Attributes.x <| toString system.frame.margin.left
  , Svg.Attributes.y <| toString system.frame.margin.top
  , Svg.Attributes.width <| toString (Coordinate.lengthX system)
  , Svg.Attributes.height <| toString (Coordinate.lengthY system)
  ]


chartAreaPlatform : Config data msg -> List (Data.Data Data.BarChart data) -> Coordinate.System -> Svg.Svg msg
chartAreaPlatform config data system =
  let
    attributes =
      List.concat
        [ [ Svg.Attributes.fill "transparent" ]
        , chartAreaAttributes system
        , Internal.Events.toChartAttributes data system config.events
        ]
  in
  Svg.rect attributes []


clipPath : Coordinate.System -> Svg.Svg msg
clipPath system =
  Svg.clipPath
    [ Svg.Attributes.id (Utils.toChartAreaId system.id) ]
    [ Svg.rect (chartAreaAttributes system) [] ]


toDataPoints : Config data msg -> Coordinate.System -> List (Bar data) -> List data -> List (Data.Data Data.BarChart data)
toDataPoints config system bars data =
  let
    userWidth =
      Internal.Bars.userWidth config.bars

    totalOfGroups =
      List.length data

    totalOfBars =
      List.length bars

    toDataPoint groupIndex datum =
      List.indexedMap (addDataPoint groupIndex datum) (List.map Internal.Bars.variable bars)

    addDataPoint groupIndex datum barIndex variable =
      { barIndex = barIndex
      , user = datum
      , point = point barIndex (Data.Point (toFloat groupIndex + 1) (variable datum)) |> Tuple.second
      }

    point =
      case config.orientation of
        Internal.Orientation.Horizontal ->
          Internal.Bars.toHorizontalBar system userWidth totalOfGroups totalOfBars

        Internal.Orientation.Vertical ->
          Internal.Bars.toVerticalBar system userWidth totalOfGroups totalOfBars
  in
  List.indexedMap toDataPoint data
    |> List.concat


toSystem : Config data msg -> Internal.Axis.Config Float data msg -> Internal.Axis.Config Float data msg -> List data -> List Coordinate.Point -> Coordinate.System
toSystem config x y data points =
  let
    independentRange toHeight =
      { min = Coordinate.minimumOrZero toHeight points
      , max = Coordinate.maximum toHeight points
      }

    dependentRange =
      { min = 0.5
      , max = toFloat (List.length data) + 0.5
      }

    ( xRange, yRange ) =
      case config.orientation of
        Internal.Orientation.Horizontal ->
          ( independentRange .x
          , dependentRange
          )

        Internal.Orientation.Vertical ->
          ( dependentRange
          , independentRange .y
          )

    container = Internal.Container.properties identity config.container
    size = Coordinate.Size (Internal.Axis.pixels x) (Internal.Axis.pixels y)
    frame  = Coordinate.Frame container.margin size

    system =
      { frame = frame
      , x = xRange
      , y = yRange
      , xData = xRange
      , yData = yRange
      , id = container.id
      }
  in
  { system
  | x = Internal.Axis.Range.applyX (Internal.Axis.range x) system
  , y = Internal.Axis.Range.applyY (Internal.Axis.range y) system
  }



-- INTERNAL / JUNK


junkDefaults :
  Config data msg
  -> List (Internal.Bars.BarConfig data)
  -> Internal.Axis.Config Float data msg
  -> Internal.Axis.Config Float data msg
  -> Internal.Junk.BarChart data
junkDefaults config bars xAxis yAxis =
  Internal.Junk.BarChart
    { hoverMany = hoverMany config bars xAxis yAxis
    , hoverOne = hoverOne config bars
    }


hoverMany :
  Config data msg
  -> List (Internal.Bars.BarConfig data)
  -> Internal.Axis.Config Float data msg
  -> Internal.Axis.Config Float data msg
  -> (data -> String)
  -> (Float -> String)
  -> List data
  -> Internal.Junk.HoverMany
hoverMany config bars xAxis yAxis formatX formatY hovered =
  let
    x = Internal.Axis.variable xAxis
    y = Internal.Axis.variable yAxis

    position =
      Maybe.map x >> Maybe.withDefault 0

    title =
      Maybe.map formatX >> Maybe.withDefault ""

    value bar datum =
      ( bar.style.base.border
      , bar.title
      , formatY (bar.variable datum)
      )
  in
  { withLine = False
  , x = position (List.head hovered)
  , title = title (List.head hovered)
  , values = List.map2 value bars hovered
  }


hoverOne :
  Config data msg
  -> List (Internal.Bars.BarConfig data)
  -> List ( String, data -> String )
  -> Internal.Events.Found Data.BarChart data
  -> Internal.Junk.HoverOne
hoverOne config bars values (Internal.Events.Found hovered) =
  let
    ( title, color ) =
      Array.fromList bars
        |> Array.get hovered.barIndex
        |> Maybe.map (\bar -> ( bar.title, bar.style.base.border ))
        |> Maybe.withDefault ( "", Colors.pink )

    applyValue ( label, value ) =
      ( label, value hovered.user )
  in
  { x = hovered.point.x
  , y = Just hovered.point.y
  , color = color
  , title = title
  , values = List.map applyValue values
  }



-- INTERNAL / DEFAULTS


defaultConfig : (data -> String) -> (data -> Float) -> Config data msg
defaultConfig label toY =
  { independentAxis = AxisIndependent.default 700 "" label
  , dependentAxis = AxisDependent.default 400 ""
  , container = Container.default "bar-chart"
  , orientation = Orientation.default
  , legends = Legends.default
  , events = Events.default
  , grid = Grid.default
  , bars = Bars.default
  , junk = Junk.default
  , pattern = Pattern.default
  }
