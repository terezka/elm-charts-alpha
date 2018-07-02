module Tooltip3 exposing (main)

import Html
import Html.Attributes
import LineChart as LineChart
import LineChart.Junk as Junk exposing (..)
import LineChart.Dots as Dots
import LineChart.Colors as Colors
import LineChart.Container as Container
import LineChart.Junk as Junk
import LineChart.Interpolation as Interpolation
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis as Axis
import LineChart.Legends as Legends
import LineChart.Line as Line
import LineChart.Events as Events
import LineChart.Unit as Unit
import LineChart.Grid as Grid
import LineChart.Legends as Legends
import LineChart.Area as Area



main : Program Never Model Msg
main =
  Html.beginnerProgram
    { model = init
    , update = update
    , view = view
    }



-- MODEL


type alias Model =
    { hovered : List (Events.Found Info) }


init : Model
init =
    { hovered = [] }



-- UPDATE


type Msg
  = Hover (List (Events.Found Info))


update : Msg -> Model -> Model
update msg model =
  case msg of
    Hover hovered ->
      { model | hovered = hovered }



-- VIEW


view : Model -> Html.Html Msg
view model =
  Html.div
    [ Html.Attributes.style [ ( "font-family", "monospace" ) ] ]
    [ chart model ]


chart : Model -> Html.Html Msg
chart model =
  LineChart.viewCustom
    { y = Axis.default 450 "Weight" Unit.kilogram (Just << .weight)
    , x = Axis.default 700 "Age" Unit.year .age
    , container = Container.styled "line-chart-1" [ ( "font-family", "monospace" ) ]
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.hoverMany Hover
    , junk = Junk.hoverMany model.hovered
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots = Dots.hoverMany (List.map Events.data model.hovered)
    }
    [ LineChart.line Colors.pink Dots.triangle "Chuck" chuck
    , LineChart.line Colors.cyan Dots.circle "Bobby" bobby
    , LineChart.line Colors.purple Dots.diamond "Alice" alice
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
  [ Info 10 34 1.34 0
  , Info 16 42 1.62 3000
  , Info 25 75 1.73 25000
  , Info 43 83 1.75 40000
  ]


bobby : List Info
bobby =
  [ Info 10 38 1.32 0
  , Info 17 69 1.75 2000
  , Info 25 75 1.87 32000
  , Info 43 77 1.87 52000
  ]


chuck : List Info
chuck =
  [ Info 10 42 1.35 0
  , Info 15 72 1.72 1800
  , Info 25 89 1.83 85000
  , Info 43 95 1.84 120000
  ]
