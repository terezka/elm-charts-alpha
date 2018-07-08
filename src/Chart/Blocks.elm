module Chart.Blocks exposing (view, Config, Series, series, Style, solid, bordered, alternate)

{-| -}

import Svg
import Svg.Attributes

import Chart.Junk as Junk
import Chart.Axis.Dependent as AxisDependent
import Chart.Axis.Independent as AxisIndependent
import Chart.Grid as Grid
import Chart.Events as Events
import Chart.Legends as Legends
import Chart.Container as Container
import Chart.Orientation as Orientation
import Chart.Pattern as Pattern
import Chart.Block as Block
import Chart.Axis.Unit as Unit
import Chart.Element as Element

import Internal.Chart
import Internal.Block
import Internal.Orientation
import Internal.Events
import Internal.Element
import Internal.Axis
import Internal.Axis.Dependent
import Internal.Axis.Independent
import Internal.Axis.Intersection
import Internal.Axis.Range
import Internal.Axis.Title
import Internal.Junk
import Internal.Container
import Internal.Pattern

import Internal.Point as Point
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
  , events : Events.Config Element.Block data msg
  , grid : Grid.Config
  , bars : Block.Config
  , junk : Junk.Config Element.Block msg
  , pattern : Pattern.Config
  }


{-| -}
type alias Series data =
  Internal.Block.Series data



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
  Internal.Block.series


-- STYLE


{-| -}
type alias Style data =
  Internal.Block.Style data


{-| -}
solid : Color.Color -> Style data
solid =
  Internal.Block.solid


{-| -}
bordered : Color.Color -> Color.Color -> Style data
bordered =
  Internal.Block.bordered


{-| -}
alternate : (Int -> data -> Bool) -> Style data -> Style data -> Style data
alternate =
  Internal.Block.alternate



-- VIEW


{-| -}
view : Config data msg -> List (Series data) -> List data -> Svg.Svg msg
view config bars data =
  let
    -- Data / System
    seriesProps = List.map Internal.Block.seriesProps bars
    countOfSeries = toFloat (List.length bars)
    countOfData = toFloat (List.length data)

    width =
      Utils.apply4 system config.bars countOfSeries countOfData <|
        Internal.Orientation.chooses config.orientation
          { horizontal = Internal.Block.width Coordinate.lengthY Coordinate.scaleDataY
          , vertical = Internal.Block.width Coordinate.lengthX Coordinate.scaleDataX
          }

    system = toSystem config horizontalAxis verticalAxis countOfData bars data
    dataPoints = toDataPoints config system countOfSeries countOfData width config.independentAxis config.dependentAxis bars data
    dataPointsAll = List.concat dataPoints

    -- Axes
    ( horizontalAxis, verticalAxis ) =
      Internal.Orientation.chooses config.orientation
        { horizontal =
            ( Internal.Axis.Dependent.toNormal config.dependentAxis data
            , Internal.Axis.Independent.toNormal config.independentAxis data
            )
        , vertical =
            ( Internal.Axis.Independent.toNormal config.independentAxis data
            , Internal.Axis.Dependent.toNormal config.dependentAxis data
            )
        }

    -- View
    viewSeries data =
      Svg.g [ Svg.Attributes.class "chart__group" ] <|
        List.map2 (Internal.Block.viewSeries system config.orientation config.bars width) bars data

    viewLegends =
      { system = system
      , config = config.legends
      , legends = \width ->
          let legend bar =
                { sample = Svg.square width (Internal.Block.borderRadius config.bars) (Internal.Block.fill bar.style) (Internal.Block.border bar.style)
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
    , junk = 
        Internal.Junk.getLayers
          { orientation = config.orientation
          , independent = Internal.Axis.Independent.title config.independentAxis 
          , dependent = Internal.Axis.Dependent.title config.dependentAxis
          , offsetOne = width / 2
          , offsetMany = width * toFloat (List.length bars) / 2
          }
          system
          config.junk
    , orientation = config.orientation
    }
    dataPointsAll
    system



-- INTERNAL


toDataPoints : Config data msg -> Coordinate.System -> Float -> Float -> Float -> AxisIndependent.Config data msg -> AxisDependent.Config msg -> List (Series data) -> List data -> List (List (Point.Point Element.Block data))
toDataPoints config system countOfSeries countOfData width independentAxis dependentAxis seriesAll data =
  let
    coordinates =
      Internal.Orientation.chooses config.orientation
        { horizontal = Coordinate.horizontalPoint
        , vertical = Coordinate.verticalPoint
        }

    eachBar dataIndex datum seriesIndex series =
      let offset = toFloat seriesIndex - countOfSeries / 2 + 0.5
          independent = toFloat dataIndex + 1 + offset * width
          dependent = Internal.Block.variable series datum
          color = Internal.Block.color series
          label = Internal.Block.label series
          coordinates_ = coordinates independent dependent
      in
      { coordinates = coordinates_
      , element =
          { element = Internal.Element.block
          , seriesIndex = seriesIndex
          , label = label
          , color = color
          , independent = Internal.Axis.Independent.label independentAxis datum
          , dependent = Internal.Axis.Dependent.unit dependentAxis dependent
          }
      , source = datum
      }

    eachSeries dataIndex datum =
      List.indexedMap (eachBar dataIndex datum) seriesAll
  in
  List.indexedMap eachSeries data


toSystem :  Config data msg -> Internal.Axis.Config Float data msg -> Internal.Axis.Config Float data msg -> Float -> List (Series data) -> List data -> Coordinate.System
toSystem config xAxis yAxis countOfData seriesAll data =
  let
    container = Internal.Container.properties identity config.container
    frame = Coordinate.frame container.margin container.size.width container.size.height 

    value data = List.map (flip Internal.Block.variable data) seriesAll
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
  { independentAxis = AxisIndependent.default "" label
  , dependentAxis = AxisDependent.default "" Unit.none
  , container = Container.default "bar-chart" 700 400
  , orientation = Orientation.default
  , legends = Legends.default
  , events = Events.default
  , grid = Grid.default
  , bars = Block.default
  , junk = Junk.default
  , pattern = Pattern.default
  }
