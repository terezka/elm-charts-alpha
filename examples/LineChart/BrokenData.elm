module BrokenData exposing (main)


import Html
import Html.Attributes exposing (class)
import LineChart
import Chart.Dot as Dots
import Chart.Junk as Junk exposing (..)
import Chart.Colors as Colors
import Chart.Container as Container
import Chart.Interpolation as Interpolation
import Chart.Axis.Intersection as Intersection
import Chart.Axis.Title as Title
import Chart.Axis.Ticks as Ticks
import Chart.Axis.Range as Range
import Chart.Axis.Unit as Unit
import Chart.Axis.Line as AxisLine
import Chart.Axis as Axis
import Chart.Legends as Legends
import Chart.Line as Line
import Chart.Events as Events
import Chart.Grid as Grid
import Chart.Legends as Legends
import Chart.Area as Area


main : Html.Html msg
main =
  Html.div
    [ class "container" ]
    [ chart ]


chart : Html.Html msg
chart =
  LineChart.viewCustom
      { y =
        Axis.custom
          { title = Title.default "Weight"
          , unit = Unit.kilograms
          , variable = .income -- or .weight -- as opposed to `Just << .height`
          , range = Range.default
          , line = AxisLine.default
          , ticks = Ticks.default
          }
      , x = Axis.default "Age" Unit.years .age
      , container = Container.styled "line-chart-1" 700 400 [ ( "font-family", "monospace" ) ]
      , interpolation = Interpolation.linear
      , intersection = Intersection.default
      , legends = Legends.default
      , events = Events.default
      , junk = Junk.default
      , grid = Grid.default
      , area = Area.stacked 0.5
      , line = Line.default
      , dots = Dots.default
      }
      [ LineChart.line Colors.gold Dots.diamond "Alice" alice
      , LineChart.line Colors.pink Dots.circle "Bobby" bobby
      , LineChart.line Colors.blue Dots.plus "Chuck" chuck
      ]



-- DATA


type alias Info =
  { age : Float
  , weight : Maybe Float
  , height : Float
  , income : Maybe Float -- This is now a Maybe!
  }


alice : List Info
alice =
  [ Info 10 (Just 34) 1.34 (Just 0)
  , Info 16 (Just 42) 1.62 (Just 3000)
  , Info 22 (Just 75) 1.73 (Just 25000)
  , Info 25 (Just 75) 1.73 (Just 25000)
  , Info 43 (Just 83) 1.75 (Just 40000)
  , Info 53 (Just 83) 1.75 (Just 80000)
  ]


bobby : List Info
bobby =
  [ Info 10 (Just 38) 1.32 (Just 0)
  , Info 16 (Just 69) 1.75 (Just 2000)
  , Info 22 (Nothing) 1.87 (Just 31000)
  , Info 25 (Nothing) 1.87 (Just 32000)
  , Info 43 (Just 77) 1.87 (Just 52000)
  , Info 53 (Just 77) 1.87 (Just 82000)
  ]


chuck : List Info
chuck =
  [ Info 10 (Just 42) 1.35 (Just 0)
  , Info 16 (Just 72) 1.72 (Just 1800)
  , Info 22 (Just 82) 1.72 (Just 90800)
  , Info 25 (Just 82) 1.72 (Nothing)
  , Info 43 (Just 95) 1.84 (Just 120000)
  , Info 53 (Just 95) 1.84 (Just 130000)
  ]
