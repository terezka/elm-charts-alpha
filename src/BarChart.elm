module BarChart exposing (view, Config, Series, series, Style, solid, bordered, alternate, isBar, isGroup)

{-| -}

import Html
import Html.Attributes
import Svg
import Svg.Attributes

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

import Internal.Chart
import Internal.Bars
import Internal.Orientation
import Internal.Events
import Internal.Axis
import Internal.Axis.Dependent
import Internal.Axis.Independent
import Internal.Axis.Intersection
import Internal.Axis.Range
import Internal.Axis.Title
import Internal.Junk
import Internal.Grid
import Internal.Container
import Internal.Pattern
import Internal.Legends

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
    -- Data / System
    seriesProps = List.map Internal.Bars.seriesProps bars
    countOfSeries = toFloat (List.length bars)
    countOfData = toFloat (List.length data)

    width =
      Utils.apply4 system config.bars countOfSeries countOfData <|
        Internal.Orientation.chooses config.orientation
          { horizontal = Internal.Bars.width Coordinate.lengthY Coordinate.scaleDataY
          , vertical = Internal.Bars.width Coordinate.lengthX Coordinate.scaleDataX
          }

    system =
      toSystem config horizontalAxis verticalAxis countOfData bars data

    dataPoints = toDataPoints config system countOfSeries countOfData width bars data
    dataPointsAll = List.concat dataPoints

    -- Axes
    ( horizontalAxis, verticalAxis ) = -- TODO swap axes
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

    -- Junk
    hoverMany formatX formatY (Internal.Events.Found hovered) =
      let value bar =
            ( Internal.Bars.color bar
            , Internal.Bars.label bar
            , formatY (Internal.Bars.variable bar hovered.user)
            )
      in
      { withLine = False
      , x = hovered.point.x
      , title = formatX hovered.user
      , values = List.map value bars
      }

    hoverOne (Internal.Events.Found hovered) =
      let independent = Internal.Axis.Independent.config config.independentAxis
          dependent = Internal.Axis.Dependent.config config.dependentAxis
          title = Internal.Axis.Title.config >> .title
      in
      { x = hovered.point.x
      , y = Just hovered.point.y
      , color = hovered.color
      , title = hovered.label
      , values =
          [ ( title independent.title, independent.label hovered.user )
          , ( title dependent.title, toString hovered.point.y ++ dependent.unit )
          ]
      }

    -- View
    viewSeries data =
      Svg.g [ Svg.Attributes.class "chart__group" ] <|
        List.map2 (Internal.Bars.viewSeries system config.orientation config.bars width) bars data

    viewLegends =
      { system = system
      , config = config.legends
      , legends = \width ->
          let legend bar =
                { sample = Svg.square width (Internal.Bars.borderRadius config.bars) (Internal.Bars.fill bar.style) (Internal.Bars.border bar.style)
                , label = bar.title
                }
          in List.map legend seriesProps
      }
  in
  Internal.Chart.view
    { container = config.container
    , events = config.events
    , defs = Internal.Pattern.toDefs config.pattern
    , grid = config.grid
    , series = Svg.g [ Svg.Attributes.class "chart__groups" ] (List.map viewSeries dataPoints)
    , intersection =
        Internal.Orientation.chooses config.orientation
          { horizontal = Internal.Axis.Intersection.custom Internal.Axis.Intersection.towardsZero .min
          , vertical = Internal.Axis.Intersection.custom .min Internal.Axis.Intersection.towardsZero
          }
    , horizontalAxis = horizontalAxis
    , verticalAxis = verticalAxis
    , legends = viewLegends
    , trends = Svg.text ""
    , junk = Internal.Junk.getLayers { hoverMany = hoverMany, hoverOne = hoverOne } config.junk
    }
    dataPointsAll
    system



-- INTERNAL


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
      , barIndex = seriesIndex -- TODO rename series index
      , color = Internal.Bars.color series
      , label = Internal.Bars.label series
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
