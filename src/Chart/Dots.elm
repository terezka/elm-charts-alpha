module Chart.Dots exposing
  ( view1, view2, view3
  , view, Group, group
  , viewCustom, Config
  )

{-|

## Table of contents

### Quick start
> [view1](#view1) for visualizing a single data series.</br>
> [view2](#view2) for visualizing two data series.</br>
> [view3](#view3) for visualizing three data series.</br>

### Customizing lines
> [view](#view) for visualizing *any* amount of data series.</br>
> [group](#group) for configuring color, dot etc. of a group representing a data series.</br>

### Customizing everything
> [viewCustom](#viewCustom) for configuring any other aspect of the chart (axis, area, etc.).</br>



# Quick start
@docs view1, view2, view3

# Customizing lines
@docs view, Group, group

# Customizing everything
@docs viewCustom, Config

-}

import Html
import Svg

import Chart.Junk as Junk
import Chart.Axis as Axis
import Chart.Axis.Unit as Unit
import Chart.Junk as Junk
import Chart.Dot as Dots
import Chart.Grid as Grid
import Chart.Dot as Dots
import Chart.Trend as Trend
import Chart.Group as Group
import Chart.Element as Element
import Chart.Colors as Colors
import Chart.Events as Events
import Chart.Legends as Legends
import Chart.Outliers as Outliers
import Chart.Container as Container
import Chart.Axis.Intersection as Intersection

import Internal.Axis
import Internal.Junk
import Internal.Dot
import Internal.Element
import Internal.Chart
import Internal.Group
import Internal.Events
import Internal.Container
import Internal.Axis.Range
import Internal.Trend
import Internal.Outliers
import Internal.Orientation

import Internal.Svg as Svg
import Internal.Point as Point
import Internal.Coordinate as Coordinate
import Color



-- VIEW / SIMPLE


{-|

** Show a line chart **

    type alias Point =
      { x : Float, y : Float }

    chart : Html msg
    chart =
      Chart.Dots.view1 .x .y
        [ Point 0 2, Point 5 5, Point 10 10 ]


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Chart-Dots/Example1.elm)._


** Choosing your variables **

Notice that we provide `.x` and `.y` to specify which data we want to show.
So if we had more complex data structures, like a human with an `age`, `weight`,
`height`, and `income`, we can easily pick which two properties we want to plot:

    chart : Html msg
    chart =
      Chart.Dots.view1 .age .weight
        [ Human  4 24 0.94     0
        , Human 25 75 1.73 25000
        , Human 43 83 1.75 40000
        ]

    -- Try changing .weight to .height


<img alt="Chart Result" width="540" src="https://github.com/terezka/line-charts/blob/master/images/ChartDots1.png?raw=true"></src>

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Chart-Dots/Example2.elm)._


** Use any function to determine inputs **

Rather than using data like `.weight` directly, you can make a
function like `bmi human = human.weight / human.height ^ 2` and create a
chart of `.age` vs `bmi`. This allows you to keep your data set nice and minimal!


** The whole chart is just a function **

`view1` is just a function, so it will update as your data changes.
If you get more data points or some data points are changed, the chart
refreshes automatically!

-}
view1 : (data -> Float) -> (data -> Float) -> List data -> Svg.Svg msg
view1 toX toY dataset =
  view toX toY <| defaultLines [ dataset ]


{-|

** Show a line chart with two lines **

Say you have two humans and you would like to see how their weight relates
to their age. Here's how you could plot it.

    chart : Html msg
    chart =
      Chart.Dots.view2 .age .weight alice chuck


<img alt="Chart Result" width="540" src="https://github.com/terezka/line-charts/blob/master/images/ChartDots2.png?raw=true"></src>

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Chart-Dots/Example3.elm)._


-}
view2 : (data -> Float) -> (data -> Float) -> List data -> List data -> Svg.Svg msg
view2 toX toY dataset1 dataset2 =
  view toX toY <| defaultLines [ dataset1, dataset2 ]


{-|

** Show a line chart with three lines **

It works just like `view1` and `view2`.

    chart : Html msg
    chart =
      Chart.Dots.view3 .age .weight alice bob chuck


<img alt="Chart Result" width="540" src="https://github.com/terezka/line-charts/blob/master/images/ChartDots3.png?raw=true"></src>

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Chart-Dots/Example4.elm)._

But what if you have more people? What if you have _four_ people?! In that case,
check out `view`.
-}
view3 : (data -> Float) -> (data -> Float) -> List data -> List data -> List data -> Svg.Svg msg
view3 toX toY dataset1 dataset2 dataset3 =
  view toX toY <| defaultLines [ dataset1, dataset2, dataset3 ]



-- VIEW


{-|

** Show any amount of lines **

If you want to change the color, the dot, or the title of a line, then see
the `line` function.

    chart : Html msg
    chart =
      Chart.Dots.view .age .height
        [ Chart.Dots.line Colors.purple Dots.cross "Alice" alice
        , Chart.Dots.line Colors.blue Dots.square "Bobby" bobby
        , Chart.Dots.line Colors.cyan Dots.circle "Chuck" chuck
        ]


<img alt="Chart Result" width="540" src="https://github.com/terezka/line-charts/blob/master/images/ChartDots4.png?raw=true"></src>

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Chart-Dots/Example5.elm)._


See `viewCustom` for all other customizations.

-}
view : (data -> Float) -> (data -> Float) -> List (Group data) -> Svg.Svg msg
view toX toY =
  viewCustom (defaultConfig toX toY)


{-| This is the type holds the visual configuration representing
a _series_ of data.

Definition of _series_:
> a number of events, objects, or people of a similar or related kind coming one after another.

** Examples of customizations **

See the `line` and `dash` functions for more information!


    solidLine : Chart.Dots.Group Human
    solidLine =
      Chart.Dots.line Colors.purple Dots.cross "Alice" alice


    dashedLine : Chart.Dots.Group Human
    dashedLine =
      Chart.Dots.dash Colors.purpleLight Dots.none "Average" [ 4, 2 ] average


-}
type alias Group data =
  Internal.Group.Group data


{-|

** Customize a solid line **

Try changing the color or explore all the available dot shapes from `Chart.Dots.Dot`!

    chart : Html msg
    chart =
      Chart.Dots.view .age .weight
        [ Chart.Dots.line Colors.pinkLight Dots.plus "Alice" alice
        , Chart.Dots.line Colors.goldLight Dots.diamond "Bobby" bobby
        , Chart.Dots.line Colors.blueLight Dots.square "Chuck" chuck
        ]

<img alt="Chart Result" width="540" src="https://github.com/terezka/line-charts/blob/master/images/ChartDots7.png?raw=true"></src>

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Chart-Dots/Example6.elm)._


** Regarding the title **

The string title will show up in the legends. If you are interested in
customizing your legends, dot size or line width, check out `viewCustom`.

 -}
group : Color.Color -> Dots.Shape -> String -> List data -> Group data
group =
  Internal.Group.group



-- VIEW / CUSTOM


{-|

** Available customizations **

Use with `viewCustom`.

  - **x**: Customizes your horizontal axis.</br>
    _See [`Chart.Dots.Axis`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Dots-Axis) for more information and examples._

  - **y**: Customizes your vertical axis.</br>
    _See [`Chart.Dots.Axis`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Dots-Axis) for more information and examples._

  - **intersection**: Determines where your axes meet.</br>
    _See [`Chart.Dots.Axis.Intersection`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Dots-Axis-Intersection) for more information and examples._

  - **interpolation**: Customizes the curve of your Chart.Dots.</br>
    _See [`Chart.Dots.Interpolation`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Dots-Interpolation) for more information and examples._

  - **container**: Customizes the container of your chart.</br>
    _See [`Chart.Dots.Container`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Dots-Container) for more information and examples._

  - **legends**: Customizes your chart's legends.</br>
    _See [`Chart.Dots.Legends`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Dots-Legends) for more information and examples._

  - **events**: Customizes your chart's events, allowing you to easily
    make your chart interactive (adding tooltips, selection states etc.).</br>
    _See [`Chart.Dots.Events`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Dots-Events) for more information and examples._

  - **grid**: Customizes the style of your grid.</br>
    _See [`Chart.Dots.Grid`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Dots-Grid) for more information and examples._

  - **area**: Customizes the area under your group.</br>
    _See [`Chart.Dots.Area`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Dots-Area) for more information and examples._

  - **line**: Customizes your lines' width and color.</br>
    _See [`Chart.Dots.Line`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Dots-Line) for more information and examples._

  - **dots**: Customizes your dots' size and style.</br>
    _See `Chart.Dots.Dot` for more information and examples._

  - **junk**: Gets its name from
    [Edward Tufte's concept of "chart junk"](https://en.wikipedia.org/wiki/Chartjunk).
    Here you are finally allowed set your creativity loose and add whatever
    SVG or HTML fun you can imagine.</br>
    _See [`Chart.Dots.Junk`](http://package.elm-lang.org/packages/terezka/line-charts/latest/Chart-Dots.Junk) for more information and examples._


** Example configuration **

A good start would be to copy it and play around with customizations
available for each property.


    chartConfig : Config Info msg
    chartConfig =
      { y = Axis.default 400 "Age" .age
      , x = Axis.default 700 "Weight" .weight
      , container = Container.default "line-chart-1"
      , interpolation = Interpolation.default
      , intersection = Intersection.default
      , legends = Legends.default
      , events = Events.default
      , junk = Junk.default
      , grid = Grid.default
      , area = Area.default
      , line = Group.default
      , dots = Dots.default
      }

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Chart-Dots/Example8.elm)._

-}
type alias Config data msg =
  { x : Axis.Config Float data msg
  , y : Axis.Config Float data msg
  , container : Container.Config msg
  , intersection : Intersection.Config
  , outliers : Outliers.Config data
  , legends : Legends.Config msg
  , events : Events.Config Element.Dot data msg
  , trend : Trend.Config data
  , grid : Grid.Config
  , line : Group.Config data
  , dots : Dots.Config data
  , junk : Junk.Config data msg
  }



{-|

** Customize everything **

See the `Config` type for information about the available customizations.
Or copy and play with the example below. No one will tell.

** Example customiztion **

The example below makes the line chart an area chart.

    chart : Html msg
    chart =
      Chart.Dots.viewCustom chartConfig
        [ Chart.Dots.line Colors.blueLight Dots.square "Chuck" chuck
        , Chart.Dots.line Colors.pinkLight Dots.plus "Alice" alice
        , Chart.Dots.line Colors.goldLight Dots.diamond "Bobby" bobby
        ]

    chartConfig : Config Info msg
    chartConfig =
      { y = Axis.default 400 "Age" .age
      , x = Axis.default 700 "Weight" .weight
      , container = Container.default "line-chart-1"
      , interpolation = Interpolation.default
      , intersection = Intersection.default
      , legends = Legends.default
      , events = Events.default
      , junk = Junk.default
      , grid = Grid.default
      , line = Group.default
      , dots = Dots.default
      }


<img alt="Chart Result" width="540" src="https://github.com/terezka/line-charts/blob/master/images/ChartDots6.png?raw=true"></src>

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Chart-Dots/Example9.elm)._


** Speaking of area charts **

Remember that area charts are for data where the area under the curve _matters_.
Typically, this would be when you have a quantity accumulating over time.
Think profit over time or velocity over time!
In the case of profit over time, the area under the curve shows the total amount
of money earned in that time frame.<br/>
If the that total amount is not important for the relationship you're
trying to visualize, it's best to leave it out!

-}
viewCustom : Config data msg -> List (Group data) -> Html.Html msg
viewCustom config lines =
  let
    -- Data
    data = toDataPoints config lines
    dataAll = List.concat data

    -- System
    system =
      toSystem config dataAll

    -- View
    viewLines =
      Internal.Group.view
        { system = system
        , dotsConfig = config.dots
        , lineConfig = config.line
        , outliersConfig = config.outliers
        }

    viewLegends =
      { system = system
      , config = config.legends
      , defaults = { width = 30, offsetY = 10 }
      , legends = \width ->
          let legend serie data =
              { sample = Internal.Group.viewSample config.dots config.line system serie data width
              , label = Internal.Group.label serie
              }
          in List.map2 legend lines data
      }
  in
  Internal.Chart.view
    { container = config.container
    , events = config.events
    , defs = []
    , grid = config.grid
    , series = viewLines lines data
    , intersection = config.intersection
    , horizontalAxis = config.x
    , verticalAxis = config.y
    , legends = viewLegends
    , trends = Internal.Trend.view system config.trend config.line lines data
    , junk =
        Internal.Junk.getLayers
          { orientation = Internal.Orientation.Vertical
          , independent = Internal.Axis.title config.x
          , dependent = Internal.Axis.title config.y
          , offsetOne = 15
          , offsetMany = 15
          }
          system
          config.junk
    , orientation = Internal.Orientation.Vertical
    }
    dataAll
    system



-- INTERNAL


toDataPoints : Config data msg -> List (Group data) -> List (List (Point.Point Element.Dot data))
toDataPoints config groups =
  let
    x = Internal.Axis.variable config.x
    y = Internal.Axis.variable config.y

    data =
      List.indexedMap eachSerie groups

    eachSerie seriesIndex group =
      let data = Internal.Group.data group
          isOutlier = Internal.Outliers.isOutlier config.outliers data
      in
      List.map (addPoint seriesIndex group isOutlier) data

    addPoint seriesIndex group isOutlier datum =
      { source = datum
      , coordinates = Coordinate.Point (x datum) (y datum)
      , element =
          { element = Internal.Element.dot (isOutlier datum)
          , label = Internal.Group.label group
          , color = Internal.Group.colorBase group
          , independent = Internal.Axis.unit config.x (x datum)
          , dependent = Internal.Axis.unit config.y (y datum)
          , seriesIndex = seriesIndex
          }
      }
  in
  data


toSystem : Config data msg -> List (Point.Point Element.Dot data) -> Coordinate.System
toSystem config data =
  let
    container = Internal.Container.properties identity config.container
    frame  = Coordinate.frame container.margin container.size.width container.size.height
    xRange = Coordinate.range (.coordinates >> .x) data
    yRange = Coordinate.range (.coordinates >> .y) data

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
  | x = Internal.Axis.Range.applyX (Internal.Axis.range config.x) system
  , y = Internal.Axis.Range.applyY (Internal.Axis.range config.y) system
  }



-- INTERNAL / DEFAULTS


defaultConfig : (data -> Float) -> (data -> Float) -> Config data msg
defaultConfig toX toY =
  { y = Axis.default "" Unit.none toY
  , x = Axis.default "" Unit.none toX
  , container = Container.default "scatter-chart-1" 700 400
  , intersection = Intersection.default
  , outliers = Outliers.default
  , legends = Legends.default
  , events = Events.default
  , trend = Trend.default
  , junk = Junk.default
  , grid = Grid.default
  , line = Group.default
  , dots = Dots.default
  }


defaultLines : List (List data) -> List (Group data)
defaultLines =
  List.map4 Internal.Group.group defaultColors defaultShapes defaultLabel


defaultColors : List Color.Color
defaultColors =
  [ Colors.pink
  , Colors.blue
  , Colors.gold
  ]


defaultShapes : List Dots.Shape
defaultShapes =
  [ Internal.Dot.Circle
  , Internal.Dot.Triangle
  , Internal.Dot.Cross
  ]


defaultLabel : List String
defaultLabel =
  [ "First"
  , "Second"
  , "Third"
  ]
