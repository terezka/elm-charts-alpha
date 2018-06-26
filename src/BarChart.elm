module BarChart exposing (view, Config, Series, series, Style, solid, bordered, alternate, isBar, isGroup)

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
import Internal.Axis.Ticks
import Internal.Axis.Title
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
type alias SeriesConfig data =
  { title : String
  , style : Style data
  , variable : data -> Float
  , pattern : Bool
  }


{-| -}
series : SeriesConfig data -> Series data
series =
  Internal.Bars.series


-- STYLE


{-| -}
type alias Style data =
  Internal.Bars.Style data


{-| -}
solid : Color.Color -> Style data
solid =
  Internal.Bars.solid


{-| -}
bordered : Color.Color -> Color.Color -> Style data
bordered =
  Internal.Bars.bordered


{-| -}
alternate : (Int -> data -> Bool) -> Style data -> Style data -> Style data
alternate =
  Internal.Bars.alternate


{-| -} -- TODO move elsewhere
isBar : Maybe (Events.Found data) -> Int -> data -> Bool
isBar =
  Internal.Bars.isBar


{-| -}
isGroup : Maybe (Events.Found data) -> Int -> data -> Bool
isGroup =
  Internal.Bars.isGroup


-- VIEW


{-| -}
view : Config data msg -> List (Series data) -> List data -> Svg.Svg msg
view config bars data =
  let
    seriesProps = List.map Internal.Bars.seriesProps bars

    -- Data
    countOfSeries = toFloat (List.length bars)
    countOfData = toFloat (List.length data)

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
      toSystem config horizontalAxis verticalAxis countOfData bars data

    -- Data points
    width =
      Utils.apply4 system config.bars countOfSeries countOfData <|
        Internal.Orientation.chooses config.orientation
          { horizontal = Internal.Bars.width Coordinate.lengthY Coordinate.scaleDataY
          , vertical = Internal.Bars.width Coordinate.lengthX Coordinate.scaleDataX
          }

    dataPoints = toDataPoints config system countOfSeries countOfData width bars data
    dataPointsAll = List.concat dataPoints

    -- Junk
    addGrid =
      Internal.Junk.addBelow <|
        Internal.Grid.view system (Internal.Axis.ticks horizontalAxis) (Internal.Axis.ticks verticalAxis) config.grid

    junkDefaults_ =
      junkDefaults config system seriesProps horizontalAxis verticalAxis config.independentAxis config.dependentAxis

    junk =
      Internal.Junk.getLayers junkDefaults_ system config.junk
        |> addGrid

    intersection =
      Internal.Orientation.chooses config.orientation
        { horizontal = Internal.Axis.Intersection.custom Internal.Axis.Intersection.towardsZero .min
        , vertical = Internal.Axis.Intersection.custom .min Internal.Axis.Intersection.towardsZero
        }

    -- View
    viewSeries data =
      Svg.g [ Svg.Attributes.class "chart__group" ] <|
        List.map2 (Internal.Bars.viewSeries system config.orientation config.bars width) bars data

    viewAllSeries =
      List.map viewSeries dataPoints

    attributes =
      List.concat
        [ Internal.Container.properties .attributesSvg config.container
        , Internal.Events.toContainerAttributes dataPointsAll system config.events
        , [ viewBoxAttribute system ]
        ]

    toLegend width bar =
      { sample = Svg.square width (Internal.Bars.borderRadius config.bars) (Internal.Bars.fill bar.style) (Internal.Bars.border bar.style)
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
      , chartAreaPlatform config dataPointsAll system
      , Svg.g [ Svg.Attributes.class "chart__groups" ] viewAllSeries
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



-- INTERNAL / DATA


toDataPoints : Config data msg -> Coordinate.System -> Float -> Float -> Float -> List (Series data) -> List data -> List (List (Data.Data Data.BarChart data))
toDataPoints config system countOfSeries countOfData width seriesAll data =
  let
    point =
      Internal.Orientation.chooses config.orientation
        { horizontal = Coordinate.horizontalPoint
        , vertical = Coordinate.verticalPoint
        }

    eachBar dataIndex datum seriesIndex series =
      let offset = toFloat seriesIndex - countOfSeries / 2 + 0.5
          independent = toFloat dataIndex + 1 + offset * width
          dependent = Internal.Bars.variable series datum
      in
      { point = point independent dependent
      , barIndex = seriesIndex -- TODO rename bar index
      , user = datum
      }

    eachSeries dataIndex datum =
      List.indexedMap (eachBar dataIndex datum) seriesAll
  in
  List.indexedMap eachSeries data


toSystem :  Config data msg -> Internal.Axis.Config Float data msg -> Internal.Axis.Config Float data msg -> Float -> List (Series data) -> List data -> Coordinate.System
toSystem config xAxis yAxis countOfData seriesAll data =
  let
    container = Internal.Container.properties identity config.container
    size = Coordinate.Size (Internal.Axis.pixels xAxis) (Internal.Axis.pixels yAxis)
    frame = Coordinate.Frame container.margin size

    value data = List.map (flip Internal.Bars.variable data) seriesAll
    values = List.concatMap value data

    dependentRange =
      { min = Coordinate.minimumOrZero identity values
      , max = Coordinate.maximumOrZero identity values
      }

    independentRange =
      { min = 0.5
      , max = countOfData + 0.5
      }

    ( xRange, yRange ) =
      Internal.Orientation.chooses config.orientation
        { horizontal = ( dependentRange, independentRange )
        , vertical = ( independentRange, dependentRange )
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


junkDefaults
  :  Config data msg
  -> Coordinate.System
  -> List (Internal.Bars.SeriesProps data)
  -> Internal.Axis.Config Float data msg
  -> Internal.Axis.Config Float data msg
  -> Internal.Axis.Independent.Config data msg
  -> Internal.Axis.Dependent.Config msg
  -> Internal.Junk.BarChart data
junkDefaults config system bars xAxis yAxis independent dependent =
  Internal.Junk.BarChart
    { hoverMany = hoverMany config bars xAxis yAxis
    , hoverOne = hoverOne config system bars independent dependent
    }


hoverMany
  :  Config data msg
  -> List (Internal.Bars.SeriesProps data)
  -> Internal.Axis.Config Float data msg
  -> Internal.Axis.Config Float data msg
  -> (data -> String)
  -> (Float -> String)
  -> List data
  -> Internal.Junk.HoverMany
hoverMany config bars xAxis yAxis formatX formatY hovered = -- first :: rest <-> hovered
  let
    x = Internal.Axis.variable xAxis
    y = Internal.Axis.variable yAxis

    position =
      Maybe.map x >> Maybe.withDefault 0

    title =
      Maybe.map formatX >> Maybe.withDefault ""

    value bar datum =
      ( Internal.Bars.border bar.style
      , bar.title
      , formatY (bar.variable datum)
      )
  in
  { withLine = False
  , x = position (List.head hovered)
  , title = title (List.head hovered)
  , values = List.map2 value bars hovered
  }


hoverOne
  :  Config data msg
  -> Coordinate.System
  -> List (Internal.Bars.SeriesProps data)
  -> Internal.Axis.Independent.Config data msg
  -> Internal.Axis.Dependent.Config msg
  -> Internal.Events.Found Data.BarChart data
  -> Internal.Junk.HoverOne
hoverOne config system bars independentSafe dependentSafe (Internal.Events.Found hovered) =
  let
    independent = Internal.Axis.Independent.config independentSafe -- x
    dependent = Internal.Axis.Dependent.config dependentSafe -- y
    title = Internal.Axis.Title.config >> .title
    ticks = Internal.Axis.Ticks.ticks system.yData system.y dependent.ticks

    ( header, color ) =
      Array.fromList bars
        |> Array.get hovered.barIndex
        |> Maybe.map (\bar -> ( bar.title, Internal.Bars.border bar.style ))
        |> Maybe.withDefault ( "", Colors.pink )

    values =
      [ ( title independent.title, independent.label hovered.user )
      , ( title dependent.title, toString hovered.point.y ++ dependent.unit )
      ]
  in
  { x = hovered.point.x
  , y = Just hovered.point.y
  , color = color
  , title = header
  , values = values
  }



-- INTERNAL / DEFAULTS


defaultConfig : (data -> String) -> (data -> Float) -> Config data msg
defaultConfig label toY =
  { independentAxis = AxisIndependent.default 700 "" label
  , dependentAxis = AxisDependent.default 400 "" ""
  , container = Container.default "bar-chart"
  , orientation = Orientation.default
  , legends = Legends.default
  , events = Events.default
  , grid = Grid.default
  , bars = Bars.default
  , junk = Junk.default
  , pattern = Pattern.default
  }
