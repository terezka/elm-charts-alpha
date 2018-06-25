module BarChart exposing (view, Config, Series, series)

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
  , bars : Bars.Config
  , junk : Junk.Config data msg
  , pattern : Pattern.Config
  }


{-| -}
type alias Series data =
  Internal.Bars.Series data


{-| -}
type alias Style =
  { fill : Color.Color
  , border : Color.Color
  }


{-| -}
type alias SeriesConfig data =
  { title : String
  , style : { base : Style, emphasized : data -> Style }
  , variable : data -> Float
  , pattern : Bool
  }


{-| -}
series : SeriesConfig data -> Series data
series =
  Internal.Bars.series


{-| -}
view : Config data msg -> List (Series data) -> List data -> Svg.Svg msg
view config bars data =
  let
    -- Data
    countOfSeries = toFloat (List.length bars)
    countOfData = toFloat (List.length data)
    seriesProps = List.map Internal.Bars.seriesProps bars
    naiveDataPoints = toNaiveDataPoints config bars data
    naiveDataPointsAll = List.concat naiveDataPoints

    -- Axes
    ( horizontalAxis, verticalAxis ) = -- swap axes
      Internal.Orientation.chooses config.orientation
        { horizontal =
            ( Internal.Axis.Dependent.toNormal data config.dependentAxis
            , Internal.Axis.Independent.toNormal data config.independentAxis
            )
        , vertical =
            ( Internal.Axis.Independent.toNormal data config.independentAxis
            , Internal.Axis.Dependent.toNormal data config.dependentAxis
            )
        }

    -- System
    system =
      toSystem config horizontalAxis verticalAxis countOfData (List.map .point naiveDataPointsAll)

    dataPoints =
      toDataPoints config system bars data naiveDataPointsAll

    -- Junk
    addGrid =
      Internal.Junk.addBelow <|
        Internal.Grid.view system (Internal.Axis.ticks horizontalAxis) (Internal.Axis.ticks verticalAxis) config.grid

    junk =
       Internal.Junk.getLayers (junkDefaults config seriesProps horizontalAxis verticalAxis) system config.junk
        |> addGrid

    intersection =
      Internal.Orientation.chooses config.orientation
        { horizontal = Internal.Axis.Intersection.custom Internal.Axis.Intersection.towardsZero .min
        , vertical = Internal.Axis.Intersection.custom .min Internal.Axis.Intersection.towardsZero
        }

    -- View
    barWidth =
      Utils.apply4 system config.bars countOfSeries countOfData <|
        Internal.Orientation.chooses config.orientation
          { horizontal = Internal.Bars.individualBarWidth Coordinate.lengthY Coordinate.scaleDataY
          , vertical = Internal.Bars.individualBarWidth Coordinate.lengthX Coordinate.scaleDataX
          }

    viewSeries =
        List.indexedMap (Internal.Bars.viewSeries system config.orientation config.bars barWidth countOfSeries data) bars

    attributes =
      List.concat
        [ Internal.Container.properties .attributesSvg config.container
        , Internal.Events.toContainerAttributes dataPoints system config.events
        , [ viewBoxAttribute system ]
        ]

    toLegend width bar =
      { sample = Svg.square width (Internal.Bars.borderRadius config.bars) bar.style.base.fill bar.style.base.border
      , label = bar.title
      }

    viewLegends =
      Internal.Legends.view
        { system = system
        , config = config.legends
        , legends = \width -> List.map (toLegend width) seriesProps
        }
  in
  container config system junk.html <|
    Svg.svg attributes
      [ Svg.defs [] (clipPath system :: Internal.Pattern.toDefs config.pattern)
      , Svg.g [ Svg.Attributes.class "chart__junk--below" ] junk.below
      , chartAreaPlatform config dataPoints system
      , Svg.g [ Svg.Attributes.class "groups" ] viewSeries
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


toNaiveDataPoints : Config data msg -> List (Series data) -> List data -> List (List (Data.Data Data.BarChart data))
toNaiveDataPoints config bars data =
  let
    toBars groupIndex datum barIndex bar =
        { point = point (toFloat groupIndex + 1) (Internal.Bars.variable bar datum)
        , barIndex = barIndex
        , user = datum
        }

    point =
      Internal.Orientation.chooses config.orientation
        { horizontal = Coordinate.horizontalPoint
        , vertical = Coordinate.verticalPoint
        }

    toGroups groupIndex datum =
      List.indexedMap (toBars groupIndex datum) bars
  in
  List.indexedMap toGroups data


toDataPoints : Config data msg -> Coordinate.System -> List (Series data) -> List data -> List (Data.Data Data.BarChart data) -> List (Data.Data Data.BarChart data)
toDataPoints config system bars data naiveDataPoints =
  let
    userWidth =
      Internal.Bars.userWidth config.bars

    totalOfGroups =
      List.length data

    totalOfBars =
      List.length bars

    toDataPoint naiveDataPoint =
      { naiveDataPoint | point = adjust naiveDataPoint.barIndex naiveDataPoint.point |> Tuple.second }

    adjust =
      case config.orientation of
        Internal.Orientation.Horizontal ->
          Internal.Bars.toHorizontalBar system userWidth totalOfGroups totalOfBars

        Internal.Orientation.Vertical ->
          Internal.Bars.toVerticalBar system userWidth totalOfGroups totalOfBars
  in
  List.map toDataPoint naiveDataPoints


toSystem :  Config data msg -> Internal.Axis.Config Float data msg -> Internal.Axis.Config Float data msg -> Float -> List Coordinate.Point -> Coordinate.System
toSystem config xAxis yAxis countOfData points =
  let
    container = Internal.Container.properties identity config.container
    size = Coordinate.Size (Internal.Axis.pixels xAxis) (Internal.Axis.pixels yAxis)
    frame = Coordinate.Frame container.margin size

    dependentRange toHeight =
      { min = Coordinate.minimumOrZero toHeight points
      , max = Coordinate.maximumOrZero toHeight points
      }

    independentRange =
      { min = 0.5
      , max = countOfData + 0.5
      }

    ( xRange, yRange ) =
      Internal.Orientation.chooses config.orientation
        { horizontal = ( dependentRange .x, independentRange )
        , vertical = ( independentRange, dependentRange .y )
        }

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
  | x = Internal.Axis.Range.applyX (Internal.Axis.range xAxis) system
  , y = Internal.Axis.Range.applyY (Internal.Axis.range yAxis) system
  }



-- INTERNAL / JUNK


junkDefaults :
  Config data msg
  -> List (Internal.Bars.SeriesProps data)
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
  -> List (Internal.Bars.SeriesProps data)
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
  -> List (Internal.Bars.SeriesProps data)
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
