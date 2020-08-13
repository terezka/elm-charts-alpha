module CustomLines exposing (main)


import Html
import Html.Attributes exposing (class)
import LineChart
import Chart.Junk as Junk exposing (..)
import Chart.Dot as Dots
import Chart.Colors as Colors
import Chart.Container as Container
import Chart.Interpolation as Interpolation
import Chart.Axis.Intersection as Intersection
import Chart.Axis as Axis
import Chart.Legends as Legends
import Chart.Line as Line
import Chart.Events as Events
import Chart.Grid as Grid
import Chart.Legends as Legends
import Chart.Area as Area
import Chart.Axis.Unit as Unit
import Color


main : Html.Html msg
main =
  Html.div
    [ class "container" ]
    [ chart ]


chart : Html.Html msg
chart =
  LineChart.viewCustom
    { y = Axis.default "Weight" Unit.kilograms .weight
    , x = Axis.default "Age" Unit.years .age
    , container = Container.styled "line-chart-1" 1000 1000 [ ( "font-family", "monospace" ) ]
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.default
    , junk = Junk.default
    , grid = Grid.default
    , area =
        -- Try out these different configs!
        -- Area.default
        -- Area.normal 0.5
        Area.stacked 0.5
    , line = Line.default
    , dots = Dots.default
    }
    [ LineChart.line Colors.pink Dots.triangle "Chuck" chuck
    , LineChart.line Colors.blue Dots.circle "Bobby" bobby
    , LineChart.line Colors.cyan Dots.diamond "Alice" alice
    ]



-- DATA


type alias Info =
  { age : Float
  , weight : Float
  , height : Float
  , income : Float
  }


alice : List Info
alice =
  [ Info 10 20 1.34 (Just 0)
  , Info 15 30 1.62 3000
  , Info 25 20 1.73 25000
  , Info 40 10 1.75 40000
  ]


bobby : List Info
bobby =
  [ Info 10 20 1.32 0
  , Info 15 30 1.75 2000
  , Info 25 20 1.87 32000
  , Info 40 10 1.87 52000
  ]


chuck : List Info
chuck =
  [ Info 10 20 1.35 0
  , Info 15 30 1.72 1800
  , Info 25 20 1.83 85000
  , Info 40 10 1.84 120000
  ]
