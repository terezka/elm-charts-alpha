module Examples.LineChart.Tooltip1 exposing (main)

import Browser
import Html exposing (Html, div, h1, node, p, text)
import Html.Attributes exposing (class)
import Svg exposing (Attribute, Svg, g, text_, tspan)
import LineChart as Lines
import Chart.Junk as Junk exposing (..)
import Chart.Dot as Dot
import Chart.Container as Container
import Chart.Junk as Junk
import Chart.Axis.Unit as Unit
import Chart.Interpolation as Interpolation
import Chart.Axis.Intersection as Intersection
import Chart.Axis as Axis
import Chart.Legends as Legends
import Chart.Line as Line
import Chart.Events as Events
import Chart.Element as Element
import Chart.Grid as Grid
import Chart.Legends as Legends
import Chart.Area as Area
import Color



main : Program () Model Msg
main =
  Browser.sandbox
    { init = init
    , update = update
    , view = view
    }



-- MODEL


type alias Model =
    { hovered : Maybe (Events.Found Element.LineDot Info) }


init : Model
init =
    { hovered = Nothing }



-- UPDATE


type Msg
  = Hover (Maybe (Events.Found Element.LineDot Info))


update : Msg -> Model -> Model
update msg model =
  case msg of
    Hover hovered ->
      { model | hovered = hovered }



-- VIEW


view : Model -> Svg Msg
view model =
  Html.div
    [ class "container" ]
    [ chart model ]


chart : Model -> Html.Html Msg
chart model =
  Lines.viewCustom
    { y = Axis.default "Weight" Unit.kilograms (Just << .weight)
    , x = Axis.default "Age" Unit.years .age
    , container = Container.styled "line-chart-1" 700 450 [ ( "font-family", "monospace" ) ]
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.hoverDot Hover
    , junk = Junk.hoverDot model.hovered
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots = Dot.hoverOne (Maybe.map Events.data model.hovered)
    }
    [ Lines.line Color.orange Dot.triangle "Chuck" chuck
    , Lines.line Color.yellow Dot.circle "Bobby" bobby
    , Lines.line Color.purple Dot.diamond "Alice" alice
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
