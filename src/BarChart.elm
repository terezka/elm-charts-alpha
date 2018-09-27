module BarChart exposing
  ( view1, view2, view3
  , view, Series, SeriesConfig, series
  , Style, solid, bordered, alternate
  , viewCustom, Config
  )

{-|

## Table of contents

### Quick start

- [view1](#view1) for visualizing a single data series.
- [view2](#view2) for visualizing two data series.
- [view3](#view3) for visualizing three data series.
- [view](#view) for visualizing *any* amount of data series.

### Customizing everything
- [viewCustom](#viewCustom) for configuring any other aspect of the chart (axis, grid, etc.).</br>



# Quick start
@docs view1, view2, view3

# Customizing blocks
@docs view, Series, SeriesConfig, series
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
import Internal.Block
import Internal.Chart
import Internal.Container
import Internal.Element
import Internal.Junk
import Internal.Pattern
import Internal.Orientation

import Internal.Point as Point
import Internal.Utils as Utils
import Internal.Coordinate as Coordinate
import Internal.Svg as Svg



-- VIEW


{-|

** Show a blocks chart **

    type alias Facts =
      { country : String, population : Float }

    chart : Html msg
    chart =
      Chart.Blocks.view1 .country .population
        [ Facts "Denmark" 5748769
        , Facts "Sweden" 10142686
        , Facts "Norway" 5295619
        ]

-}
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


{-|

** Show a blocks chart with two series **

    type alias Facts =
      { country : String
      , population : Float
      , women : Float
      }

    chart : Html msg
    chart =
      Chart.Blocks.view1 .country .population .women
        [ Facts "Denmark" 5.7 2.9
        , Facts "Sweden" 10.1 5.0
        , Facts "Norway" 5.2 2.6
        ]

-}
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


{-|

** Show a blocks chart with three series **

    type alias Facts =
      { country : String
      , population : Float
      , women : Float
      , children : Float
      }

    chart : Html msg
    chart =
      Chart.Blocks.view1 .country .population .women .children
        [ Facts "Denmark" 5.7 2.9 0.9
        , Facts "Sweden" 10.1 5.0 2.0
        , Facts "Norway" 5.2 2.6 0.8
        ]

-}
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



-- VIEW / ANY AMOUNT


{-|

** Show any amount of lines **

    chart : Html msg
    chart =
      Chart.Blocks.view .label [ denmark, norway, sweden, iceland ] data

    denmark : Chart.Blocks.Series Data
    denmark =
      Chart.Blocks.series
        { title = "Denmark"
        , style = Chart.Blocks.bordered Colors.pinkLight Colors.pink
        , variable = .denmark
        , pattern = False
        }

    norway : Chart.Blocks.Series Data
    norway =
      Chart.Blocks.series
        { title = "Norway"
        , style = Chart.Blocks.bordered Colors.blueLight Colors.blue
        , variable = .norway
        , pattern = False
        }

    sweden : Chart.Blocks.Series Data
    sweden =
      Chart.Blocks.series
        { title = "Sweden"
        , style = Chart.Blocks.bordered Colors.cyanLight Colors.cyan
        , variable = .sweden
        , pattern = False
        }

    iceland : Chart.Blocks.Series Data
    iceland =
      Chart.Blocks.series
        { title = "Iceland"
        , style = Chart.Blocks.bordered Colors.goldLight Colors.gold
        , variable = .iceland
        , pattern = False
        }

-}
view : (data -> String) -> List (Series data) -> List data -> Svg.Svg msg
view toInd =
  viewCustom (defaultConfig toInd)


{-| This type represents the configuration of a series of blocks.
-}
type alias Series data =
  Internal.Block.Series data


{-| -}
type alias SeriesConfig data =
  { title : String
  , style : Style data
  , variable : data -> Float
  , pattern : Bool
  }


{-| This is the configuration of visual properties of
a series of blocks.

** Examples of customizations **

    solidBlocks : Chart.Blocks.Series Human
    solidBlocks =
      Chart.Blocks.series  Dots.cross "Alice" alice
        { title = "Total Population"
        , style = Chart.Blocks.solid Colors.purple
        , variable = .population
        , pattern = False
        }

    stripedBlocks : Chart.Blocks.Series Human
    stripedBlocks =
      Chart.Blocks.series
        { title = "Expected Population"
        , style = Chart.Blocks.solid Colors.purple
        , variable = .expectedPopulation
        , pattern = True -- This makes it striped!
        }
-}
series : SeriesConfig data -> Series data
series =
  Internal.Block.series



-- STYLE


{-| The style of a block.
-}
type alias Style data =
  Internal.Block.Style data


{-| A solid block. Pass the color.
-}
solid : Color.Color -> Style data
solid =
  Internal.Block.solid


{-| A block with a border. Pass the main color and the border color respectively.
-}
bordered : Color.Color -> Color.Color -> Style data
bordered =
  Internal.Block.bordered


{-|

Change the style of the block based on the index and data.

    blockStyle : Chart.Blocks.Style Data
    blockStyle =
      Chart.Blocks.alternate isNumberThree
        (Chart.Blocks.solid Chart.Colors.pinkLight) -- shown when condition is false
        (Chart.Blocks.solid Chart.Colors.pink) -- shown when condition is true

    isNumberThree : Int -> Data -> Bool
    isNumberThree index _ =
      index == 3

    isHovered : Model -> Int -> Data -> Bool
    isHovered model index datum =
      datum == model.hovered


This is nice to use with `Chart.Events.isSeries`, `Chart.Events.isDatum`,
and `Chart.Events.isExactly` when working with events. See `Chart.Events`
for more information and examples.


See `viewCustom` for all other customizations.

-}
alternate : (Int -> data -> Bool) -> Style data -> Style data -> Style data
alternate =
  Internal.Block.alternate



-- VIEW / CUSTOM


{-| -}
type alias Config data msg =
  { independentAxis : Chart.Axis.Independent.Config data msg
  , dependentAxis : Chart.Axis.Dependent.Config msg
  , container : Chart.Container.Config msg
  , orientation : Chart.Orientation.Config
  , legends : Chart.Legends.Config msg
  , events : Chart.Events.Config Chart.Element.Block data msg
  , grid : Chart.Grid.Config
  , block : Chart.Block.Config
  , junk : Chart.Junk.Config Chart.Element.Block msg
  , pattern : Chart.Pattern.Config
  }



{-|
** Available customizations **

Use with `viewCustom`.

  - **x**: Customizes your independent axis.</br>
    _See [`Chart.Axis.Independent`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Axis-Independent) for more information and examples._

  - **y**: Customizes your dependent axis.</br>
    _See [`Chart.Axis.Dependent`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Axis-Dependent) for more information and examples._

  - **container**: Customizes the container of your chart.</br>
    _See [`Chart.Container`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Container) for more information and examples._

  - **legends**: Customizes your chart's legends.</br>
    _See [`Chart.Legends`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Legends) for more information and examples._

  - **events**: Customizes your chart's events, allowing you to easily
    make your chart interactive (adding tooltips, selection states etc.).</br>
    _See [`Chart.Events`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Events) for more information and examples._

  - **grid**: Customizes the style of your grid.</br>
    _See [`Chart.Grid`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Grid) for more information and examples._

  - **block**: Customizes your block width and corner radius.</br>
    _See [`Chart.Block`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Block) for more information and examples._

  - **pattern**: Customizes your blocks pattern.</br>
    _See [`Chart.Pattern`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Pattern) for more information and examples._

  - **junk**: Gets its name from
    [Edward Tufte's concept of "chart junk"](https://en.wikipedia.org/wiki/Chartjunk).
    Here you are finally allowed set your creativity loose and add whatever
    SVG or HTML fun you can imagine.</br>
    _See [`Chart.Junk`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Junk) for more information and examples._


** Example configuration **

A good start would be to copy it and play around with customizations
available for each property.


    chartConfig : Config Info msg
    chartConfig =
      { independentAxis = Chart.Axis.Independent.default "Country" .country
      , dependentAxis = Chart.Axis.Dependent.default "GDP" Chart.Axis.Unit.dollars
      , container = Chart.Container.default "blocks-chart" 700 400
      , orientation = Chart.Orientation.default
      , legends = Chart.Legends.default
      , events = Chart.Events.default
      , grid = Chart.Grid.default
      , block = Chart.Block.default
      , junk = Chart.Junk.default
      , pattern = Chart.Pattern.default
      }


-}
viewCustom : Config data msg -> List (Series data) -> List data -> Svg.Svg msg
viewCustom config block data =
  let
    -- Data / System
    seriesProps = List.map Internal.Block.seriesProps block
    countOfSeries = toFloat (List.length block)
    countOfData = toFloat (List.length data)

    width =
      Utils.apply4 system config.block countOfSeries countOfData <|
        Internal.Orientation.chooses config.orientation
          { horizontal = Internal.Block.width Coordinate.lengthY Coordinate.scaleDataY
          , vertical = Internal.Block.width Coordinate.lengthX Coordinate.scaleDataX
          }

    system = toSystem config horizontalAxis verticalAxis countOfData block data
    dataPoints = toDataPoints config system countOfSeries countOfData width block data
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
        List.map2 (Internal.Block.viewSeries system config.orientation config.block width) block data

    viewLegends =
      { system = system
      , config = config.legends
      , defaults = { width = 10, offsetY = 0 }
      , legends = \width ->
          let legend bar =
                { sample = Svg.square bar.pattern width (Internal.Block.borderRadius config.block) (Internal.Block.fill bar.style) (Internal.Block.border bar.style)
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
          , offsetMany = width * toFloat (List.length block) / 2
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
  , block = Chart.Block.default
  , junk = Chart.Junk.default
  , pattern = Chart.Pattern.default
  }

