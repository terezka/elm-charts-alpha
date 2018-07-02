module LineChart exposing
  ( view1, view2, view3
  , view, Series, line, dash
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
> [line](#line) for configuring color, dot etc. of a line representing a data series.</br>
> [dash](#dash) for configuring color, dot etc. of a *dashed* line representing a data series.</br>

### Customizing everything
> [viewCustom](#viewCustom) for configuring any other aspect of the chart (axis, area, etc.).</br>



# Quick start
@docs view1, view2, view3

# Customizing lines
@docs view, Series, line, dash

# Customizing everything
@docs viewCustom, Config

-}

import Html
import Svg

import LineChart.Junk as Junk
import LineChart.Unit as Unit
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Dots as Dots
import LineChart.Grid as Grid
import LineChart.Line as Line
import LineChart.Colors as Colors
import LineChart.Events as Events
import LineChart.Legends as Legends
import LineChart.Container as Container
import LineChart.Interpolation as Interpolation
import LineChart.Axis.Intersection as Intersection

import Internal.Chart
import Internal.Area
import Internal.Axis
import Internal.Junk
import Internal.Line
import Internal.Events
import Internal.Container
import Internal.Axis.Range
import Internal.Orientation

import Internal.Svg as Svg
import Internal.Data as Data
import Internal.Utils as Utils
import Internal.Coordinate as Coordinate
import Color



-- VIEW / SIMPLE


{-|

** Show a line chart **

    type alias Point =
      { x : Float, y : Float }

    chart : Html msg
    chart =
      LineChart.view1 .x .y
        [ Point 0 2, Point 5 5, Point 10 10 ]


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/LineChart/Example1.elm)._


** Choosing your variables **

Notice that we provide `.x` and `.y` to specify which data we want to show.
So if we had more complex data structures, like a human with an `age`, `weight`,
`height`, and `income`, we can easily pick which two properties we want to plot:

    chart : Html msg
    chart =
      LineChart.view1 .age .weight
        [ Human  4 24 0.94     0
        , Human 25 75 1.73 25000
        , Human 43 83 1.75 40000
        ]

    -- Try changing .weight to .height


<img alt="Chart Result" width="540" src="https://github.com/terezka/line-charts/blob/master/images/linechart1.png?raw=true"></src>

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/LineChart/Example2.elm)._


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
      LineChart.view2 .age .weight alice chuck


<img alt="Chart Result" width="540" src="https://github.com/terezka/line-charts/blob/master/images/linechart2.png?raw=true"></src>

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/LineChart/Example3.elm)._


-}
view2 : (data -> Float) -> (data -> Float) -> List data -> List data -> Svg.Svg msg
view2 toX toY dataset1 dataset2 =
  view toX toY <| defaultLines [ dataset1, dataset2 ]


{-|

** Show a line chart with three lines **

It works just like `view1` and `view2`.

    chart : Html msg
    chart =
      LineChart.view3 .age .weight alice bob chuck


<img alt="Chart Result" width="540" src="https://github.com/terezka/line-charts/blob/master/images/linechart3.png?raw=true"></src>

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/LineChart/Example4.elm)._

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
      LineChart.view .age .height
        [ LineChart.line Colors.purple Dots.cross "Alice" alice
        , LineChart.line Colors.blue Dots.square "Bobby" bobby
        , LineChart.line Colors.cyan Dots.circle "Chuck" chuck
        ]


<img alt="Chart Result" width="540" src="https://github.com/terezka/line-charts/blob/master/images/linechart4.png?raw=true"></src>

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/LineChart/Example5.elm)._


See `viewCustom` for all other customizations.

-}
view : (data -> Float) -> (data -> Float) -> List (Series data) -> Svg.Svg msg
view toX toY =
  viewCustom (defaultConfig toX toY)


{-| This is the type holds the visual configuration representing
a _series_ of data.

Definition of _series_:
> a number of events, objects, or people of a similar or related kind coming one after another.

** Examples of customizations **

See the `line` and `dash` functions for more information!


    solidLine : LineChart.Series Human
    solidLine =
      LineChart.line Colors.purple Dots.cross "Alice" alice


    dashedLine : LineChart.Series Human
    dashedLine =
      LineChart.dash Colors.purpleLight Dots.none "Average" [ 4, 2 ] average


-}
type alias Series data =
  Internal.Line.Series data


{-|

** Customize a solid line **

Try changing the color or explore all the available dot shapes from `LineChart.Dots`!

    chart : Html msg
    chart =
      LineChart.view .age .weight
        [ LineChart.line Colors.pinkLight Dots.plus "Alice" alice
        , LineChart.line Colors.goldLight Dots.diamond "Bobby" bobby
        , LineChart.line Colors.blueLight Dots.square "Chuck" chuck
        ]

<img alt="Chart Result" width="540" src="https://github.com/terezka/line-charts/blob/master/images/linechart7.png?raw=true"></src>

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/LineChart/Example6.elm)._


** Regarding the title **

The string title will show up in the legends. If you are interested in
customizing your legends, dot size or line width, check out `viewCustom`.

 -}
line : Color.Color -> Dots.Shape -> String -> List data -> Series data
line =
  Internal.Line.line


{-|

** Customize a dashed line **

Works just like `line`, except it takes another argument which is an array of
floats describing your dashing pattern. I recommend typing in random numbers and seeing what
happens, but you alternativelly you can see the SVG `stroke-dasharray`
[documentation](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-dasharray)
for examples of patterns.

    chart : Html msg
    chart =
      LineChart.view .age .height
        [ LineChart.line Colors.pinkLight Dots.plus "Alice" alice
        , LineChart.line Colors.goldLight Dots.diamond "Bobby" bobby
        , LineChart.line Colors.blueLight Dots.square "Chuck" chuck
        , dashedLine
        ]

    dashedLine : LineChart.Series Human
    dashedLine =
      LineChart.dash Colors.purpleLight Dots.none "Average" [ 4, 2 ] average
      --                                                    ^^^^^^^^
      -- (Scroll to the left to see the pattern!)
      -- Try passing different numbers!

<img alt="Chart Result" width="540" src="https://github.com/terezka/line-charts/blob/master/images/linechart5.png?raw=true"></src>

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/LineChart/Example7.elm)._


** When should I use a dashed line? **

Dashed lines are especially good for visualizing processed data like
averages or predicted values.

-}
dash : Color.Color -> Dots.Shape -> String -> List Float -> List data -> Series data
dash =
  Internal.Line.dash



-- VIEW / CUSTOM


{-|

** Available customizations **

Use with `viewCustom`.

  - **x**: Customizes your horizontal axis.</br>
    _See [`LineChart.Axis`](http://package.elm-lang.org/packages/terezka/line-charts/latest/LineChart-Axis) for more information and examples._

  - **y**: Customizes your vertical axis.</br>
    _See [`LineChart.Axis`](http://package.elm-lang.org/packages/terezka/line-charts/latest/LineChart-Axis) for more information and examples._

  - **intersection**: Determines where your axes meet.</br>
    _See [`LineChart.Axis.Intersection`](http://package.elm-lang.org/packages/terezka/line-charts/latest/LineChart-Axis-Intersection) for more information and examples._

  - **interpolation**: Customizes the curve of your LineChart.</br>
    _See [`LineChart.Interpolation`](http://package.elm-lang.org/packages/terezka/line-charts/latest/LineChart-Interpolation) for more information and examples._

  - **container**: Customizes the container of your chart.</br>
    _See [`LineChart.Container`](http://package.elm-lang.org/packages/terezka/line-charts/latest/LineChart-Container) for more information and examples._

  - **legends**: Customizes your chart's legends.</br>
    _See [`LineChart.Legends`](http://package.elm-lang.org/packages/terezka/line-charts/latest/LineChart-Legends) for more information and examples._

  - **events**: Customizes your chart's events, allowing you to easily
    make your chart interactive (adding tooltips, selection states etc.).</br>
    _See [`LineChart.Events`](http://package.elm-lang.org/packages/terezka/line-charts/latest/LineChart-Events) for more information and examples._

  - **grid**: Customizes the style of your grid.</br>
    _See [`LineChart.Grid`](http://package.elm-lang.org/packages/terezka/line-charts/latest/LineChart-Grid) for more information and examples._

  - **area**: Customizes the area under your line.</br>
    _See [`LineChart.Area`](http://package.elm-lang.org/packages/terezka/line-charts/latest/LineChart-Area) for more information and examples._

  - **line**: Customizes your lines' width and color.</br>
    _See [`LineChart.Line`](http://package.elm-lang.org/packages/terezka/line-charts/latest/LineChart-Line) for more information and examples._

  - **dots**: Customizes your dots' size and style.</br>
    _See `LineChart.Dots` for more information and examples._

  - **junk**: Gets its name from
    [Edward Tufte's concept of "chart junk"](https://en.wikipedia.org/wiki/Chartjunk).
    Here you are finally allowed set your creativity loose and add whatever
    SVG or HTML fun you can imagine.</br>
    _See [`LineChart.Junk`](http://package.elm-lang.org/packages/terezka/line-charts/latest/LineChart.Junk) for more information and examples._


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
      , line = Line.default
      , dots = Dots.default
      }

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/LineChart/Example8.elm)._

-}
type alias Config data msg =
  { x : Axis.Config Float data msg
  , y : Axis.Config (Maybe Float) data msg
  , container : Container.Config msg
  , intersection : Intersection.Config
  , interpolation : Interpolation.Config
  , legends : Legends.Config msg
  , events : Events.Config data msg
  , area : Area.Config
  , grid : Grid.Config
  , line : Line.Config data
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
      LineChart.viewCustom chartConfig
        [ LineChart.line Colors.blueLight Dots.square "Chuck" chuck
        , LineChart.line Colors.pinkLight Dots.plus "Alice" alice
        , LineChart.line Colors.goldLight Dots.diamond "Bobby" bobby
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
      , area = Area.stacked 0.5 -- Changed from the default!
      , line = Line.default
      , dots = Dots.default
      }


<img alt="Chart Result" width="540" src="https://github.com/terezka/line-charts/blob/master/images/linechart6.png?raw=true"></src>

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/LineChart/Example9.elm)._


** Speaking of area charts **

Remember that area charts are for data where the area under the curve _matters_.
Typically, this would be when you have a quantity accumulating over time.
Think profit over time or velocity over time!
In the case of profit over time, the area under the curve shows the total amount
of money earned in that time frame.<br/>
If the that total amount is not important for the relationship you're
trying to visualize, it's best to leave it out!

-}
viewCustom : Config data msg -> List (Series data) -> Html.Html msg
viewCustom config series =
  let
    -- Data / System
    data = toDataPoints config series
    dataSafe = List.map (List.filter .isReal) data
    dataAll = List.concat data
    dataAllSafe = List.concat dataSafe
    system = toSystem config dataAllSafe

    -- Junk
    hoverMany (Internal.Events.Found first) all =
      { line = Svg.verticalGrid [] first.point.x
      , position = { x = Just first.point.x, y = Nothing }
      , offset = { x = 15, y = 0 }
      , title = Internal.Axis.title config.x ++ ": " ++ Internal.Axis.unit config.x first.point.x
      , values =
          let value (Internal.Events.Found datum) =
                ( datum.color
                , datum.label
                , Internal.Axis.unit config.y datum.point.y
                )
          in List.map value all
      }

    hoverOne (Internal.Events.Found datum) =
      { position = { x = Just datum.point.x, y = Just datum.point.y }
      , offset = { x = 15, y = 0 }
      , color = datum.color
      , title = datum.label
      , values =
          [ ( Internal.Axis.title config.x, Internal.Axis.unit config.x datum.point.x  )
          , ( Internal.Axis.title config.y, Internal.Axis.unit config.y datum.point.y )
          ]
      }

    -- View
    viewLines =
      Internal.Line.view
        { system = system
        , interpolation = config.interpolation
        , dotsConfig = config.dots
        , lineConfig = config.line
        , area = config.area
        }

    viewLegends =
      { system = system
      , config = config.legends
      , legends = \width ->
          let legend serie data =
                { sample = Internal.Line.viewSample config.dots config.line config.area system serie data width
                , label = Internal.Line.label serie
                }
          in List.map2 legend series dataSafe
      }
  in
  Internal.Chart.view
    { container = config.container
    , events = config.events
    , defs = []
    , grid = config.grid
    , series = viewLines series data
    , intersection = config.intersection
    , horizontalAxis = config.x
    , verticalAxis = config.y
    , legends = viewLegends
    , trends = Svg.text ""
    , junk = Internal.Junk.getLayers { hoverMany = hoverMany, hoverOne = hoverOne } config.junk
    , orientation = Internal.Orientation.Vertical
    }
    dataAll
    system



-- INTERNAL


toDataPoints : Config data msg -> List (Series data) -> List (List (Data.LineChart data))
toDataPoints config series =
  let
    x = Internal.Axis.variable config.x
    y = Internal.Axis.variable config.y

    data =
      List.indexedMap eachSerie series

    eachSerie seriesIndex serie =
      List.map (eachDatum seriesIndex serie) (Internal.Line.data serie)

    eachDatum seriesIndex serie datum =
      case ( x datum, y datum ) of
        ( x, Just y ) ->
          { user = datum
          , point = Data.Point x y
          , isReal = True
          , label = Internal.Line.label serie
          , color = Internal.Line.colorBase serie
          , seriesIndex = seriesIndex
          }

        ( x, Nothing ) ->
          { user = datum
          , point = Data.Point x 0
          , isReal = False
          , label = Internal.Line.label serie
          , color = Internal.Line.colorBase serie
          , seriesIndex = seriesIndex
          }
  in
  case config.area of
    Internal.Area.None         -> data
    Internal.Area.Normal _     -> data
    Internal.Area.Stacked _    -> stack data
    Internal.Area.Percentage _ -> normalize (stack data) -- TODO Not used


stack : List (List (Data.LineChart data)) -> List (List (Data.LineChart data))
stack dataset =
  let
    stackBelows dataset result =
      case dataset of
        data :: belows ->
          stackBelows belows <|
            List.foldl addBelows data belows :: result

        [] ->
          result
  in
  List.reverse (stackBelows dataset [])


addBelows : List (Data.LineChart data) -> List (Data.LineChart data) -> List (Data.LineChart data)
addBelows data dataBelow =
  let
    iterate datum0 data dataBelow result =
      case ( data, dataBelow ) of
        ( datum1 :: data, datumBelow :: dataBelow ) ->
          -- if the data point is after the point below, add it
          if datum1.point.x > datumBelow.point.x
            then
              if datumBelow.isReal then
                iterate datum0 (datum1 :: data) dataBelow (add datumBelow datum0 :: result)
              else
                let breakdata = { datum0 | isReal = False } in
                iterate datum0 (datum1 :: data) dataBelow (add datumBelow datum0 :: result)
            -- if not, try the next
            else iterate datum1 data (datumBelow :: dataBelow) result

        ( [], datumBelow :: dataBelow ) ->
          -- if the data point is after the point below, add it
          if datum0.point.x <= datumBelow.point.x
            then iterate datum0 [] dataBelow (add datumBelow datum0 :: result)
            -- if not, try the next
            else iterate datum0 [] dataBelow (datumBelow :: result)

        ( datum1 :: data, [] ) ->
          result

        ( [], [] ) ->
          result

    add below datum =
      setY below (below.point.y + datum.point.y)
  in
  List.reverse <| Maybe.withDefault [] <| Utils.withFirst data <| \first rest ->
    iterate first rest dataBelow []


normalize : List (List (Data.LineChart data)) -> List (List (Data.LineChart data))
normalize datasets =
  case datasets of
    highest :: belows ->
      let
        toPercentage highest datum =
          setY datum (100 * datum.point.y / highest.point.y)
      in
      List.map (List.map2 toPercentage highest) (highest :: belows)

    [] ->
      datasets


setY : Data.LineChart data -> Float -> Data.LineChart data
setY datum y =
  { datum | point = Data.Point datum.point.x y, isReal = False }


toSystem : Config data msg -> List (Data.LineChart data) -> Coordinate.System
toSystem config data =
  let
    container = Internal.Container.properties identity config.container
    hasArea = Internal.Area.hasArea config.area
    size   = Coordinate.Size (Internal.Axis.pixels config.x) (Internal.Axis.pixels config.y)
    frame  = Coordinate.Frame container.margin size
    xRange = Coordinate.range (.point >> .x) data
    yRange = Coordinate.range (.point >> .y) data

    system =
      { frame = frame
      , x = xRange
      , y = adjustDomainRange yRange
      , xData = xRange
      , yData = yRange
      , id = container.id
      }

    adjustDomainRange domain =
      if hasArea
        then Coordinate.ground domain
        else domain
  in
  { system
  | x = Internal.Axis.Range.applyX (Internal.Axis.range config.x) system
  , y = Internal.Axis.Range.applyY (Internal.Axis.range config.y) system
  }


-- INTERNAL / DEFAULTS


defaultConfig : (data -> Float) -> (data -> Float) -> Config data msg
defaultConfig toX toY =
  { x = Axis.default 700 "" Unit.none toX
  , y = Axis.default 400 "" Unit.none (Just << toY)
  , container = Container.default "line-chart-1"
  , interpolation = Interpolation.default
  , intersection = Intersection.default
  , legends = Legends.default
  , events = Events.default
  , junk = Junk.default
  , grid = Grid.default
  , area = Area.default
  , line = Line.default
  , dots = Dots.default
  }


defaultLines : List (List data) -> List (Series data)
defaultLines =
  List.map4 Internal.Line.line defaultColors defaultShapes defaultLabel


defaultColors : List Color.Color
defaultColors =
  [ Colors.pink
  , Colors.blue
  , Colors.gold
  ]


defaultShapes : List Dots.Shape
defaultShapes =
  [ Dots.circle
  , Dots.triangle
  , Dots.cross
  ]


defaultLabel : List String
defaultLabel =
  [ "First"
  , "Second"
  , "Third"
  ]
