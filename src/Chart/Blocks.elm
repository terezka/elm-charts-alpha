module Chart.Blocks exposing 
  ( view1, view2, view3
  , view, Series, series
  , Style, solid, bordered, alternate
  , viewCustom, Config
  )

{-| 

## Table of contents

### Quick start
> [view1](#view1) for visualizing a single data series.</br>
> [view2](#view2) for visualizing two data series.</br>
> [view3](#view3) for visualizing three data series.</br>
> [view](#view) for visualizing *any* amount of data series.</br>

### Customizing everything
> [viewCustom](#viewCustom) for configuring any other aspect of the chart (axis, grid, etc.).</br>


# Quick start
@docs view1, view2, view3

# Customizing blocks
@docs view, Series, series
@docs Style, solid, bordered, alternate

# Customizing everything
@docs viewCustom, Config

-}

import Svg
import Svg.Attributes
import Color

import Chart.Axis.Unit
import Chart.Axis.Dependent
import Chart.Axis.Independent
import Chart.Block
import Chart.Colors
import Chart.Container
import Chart.Element
import Chart.Events
import Chart.Grid
import Chart.Junk
import Chart.Legends
import Chart.Orientation
import Chart.Pattern

import Internal.Axis
import Internal.Axis.Dependent
import Internal.Axis.Independent
import Internal.Axis.Intersection
import Internal.Axis.Range
import Internal.Axis.Title
import Internal.Block
import Internal.Chart
import Internal.Container
import Internal.Element
import Internal.Events
import Internal.Junk
import Internal.Pattern
import Internal.Orientation

import Internal.Point as Point
import Internal.Utils as Utils
import Internal.Coordinate as Coordinate
import Internal.Svg as Svg


{-| -}
type alias Config data msg =
  { independentAxis : Chart.Axis.Independent.Config data msg
  , dependentAxis : Chart.Axis.Dependent.Config msg
  , container : Chart.Container.Config msg
  , orientation : Chart.Orientation.Config
  , legends : Chart.Legends.Config msg
  , events : Chart.Events.Config Chart.Element.Block data msg
  , grid : Chart.Grid.Config
  , bars : Chart.Block.Config
  , junk : Chart.Junk.Config Chart.Element.Block msg
  , pattern : Chart.Pattern.Config
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
view1 : (data -> String) -> (data -> Float) -> List data -> Svg.Svg msg
view1 toInd toDep =
  viewCustom (defaultConfig toInd)
    [ series
        { title = "Serie 1"
        , style = solid Chart.Colors.pink
        , variable = toDep
        , pattern = False
        }
    ]


{-| -}
view2 : (data -> String) -> (data -> Float) -> (data -> Float) -> List data -> Svg.Svg msg
view2 toInd toDep1 toDep2 =
  viewCustom (defaultConfig toInd)
    [ series
        { title = "Serie 1"
        , style = solid Chart.Colors.blue
        , variable = toDep1
        , pattern = False
        }
    , series
        { title = "Serie 2"
        , style = solid Chart.Colors.pink
        , variable = toDep2
        , pattern = False
        }
    ]


{-| -}
view3 : (data -> String) -> (data -> Float) -> (data -> Float) -> (data -> Float) -> List data -> Svg.Svg msg
view3 toInd toDep1 toDep2 toDep3 =
  viewCustom (defaultConfig toInd)
    [ series
        { title = "Serie 1"
        , style = solid Chart.Colors.blue
        , variable = toDep1
        , pattern = False
        }
    , series
        { title = "Serie 2"
        , style = solid Chart.Colors.pink
        , variable = toDep2
        , pattern = False
        }
    , series
        { title = "Serie 3"
        , style = solid Chart.Colors.cyanLight
        , variable = toDep3
        , pattern = False
        }
    ]


{-| -}
view : (data -> String) -> List (Series data) -> List data -> Svg.Svg msg
view toInd =
  viewCustom (defaultConfig toInd)


{-| -}
viewCustom : Config data msg -> List (Series data) -> List data -> Svg.Svg msg
viewCustom config bars data =
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
    dataPoints = toDataPoints config system countOfSeries countOfData width bars data
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
      , defaults = { width = 10, offsetY = 0 }
      , legends = \width ->
          let legend bar =
                { sample = Svg.square bar.pattern width (Internal.Block.borderRadius config.bars) (Internal.Block.fill bar.style) (Internal.Block.border bar.style)
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


toDataPoints : Config data msg -> Coordinate.System -> Float -> Float -> Float -> List (Series data) -> List data -> List (List (Point.Point Internal.Element.Block data))
toDataPoints config system countOfSeries countOfData width seriesAll data =
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
          , independent = Internal.Axis.Independent.label config.independentAxis datum
          , dependent = Internal.Axis.Dependent.unit config.dependentAxis dependent
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


defaultConfig : (data -> String) -> Config data msg
defaultConfig label =
  { independentAxis = Chart.Axis.Independent.default "" label
  , dependentAxis = Chart.Axis.Dependent.default "" Chart.Axis.Unit.none
  , container = Chart.Container.default "bar-chart" 700 400
  , orientation = Chart.Orientation.default
  , legends = Chart.Legends.default
  , events = Chart.Events.default
  , grid = Chart.Grid.default
  , bars = Chart.Block.default
  , junk = Chart.Junk.default
  , pattern = Chart.Pattern.default
  }

