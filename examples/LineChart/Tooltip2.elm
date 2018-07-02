module Tooltip exposing (main)

import Html exposing (Html, div, h1, node, p, text)
import Html.Attributes exposing (class)
import Svg exposing (Attribute, Svg, g, text_, tspan)
import LineChart as LineChart
import LineChart.Junk as Junk exposing (..)
import LineChart.Dots as Dots
import LineChart.Container as Container
import LineChart.Coordinate as Coordinate
import LineChart.Junk as Junk
import LineChart.Interpolation as Interpolation
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis as Axis
import LineChart.Legends as Legends
import LineChart.Line as Line
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Unit as Unit
import LineChart.Legends as Legends
import LineChart.Area as Area
import Color



main : Program Never Model Msg
main =
  Html.beginnerProgram
    { model = init
    , update = update
    , view = view
    }



-- MODEL


type alias Model =
    { hovered : Maybe (Events.Found Info) }


init : Model
init =
    { hovered = Nothing }



-- UPDATE


type Msg
  = Hover (Maybe (Events.Found Info))


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
  LineChart.viewCustom
    { y = Axis.default 450 "Weight" Unit.kilogram (Just << .weight)
    , x = Axis.default 700 "Age" Unit.year .age
    , container = Container.styled "line-chart-1" [ ( "font-family", "monospace" ) ]
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.default
    , events = Events.hoverOne Hover
    , junk =
        let
          html =
            case model.hovered of
                Just info -> [ tooltip (Events.data info) ]
                Nothing   -> []
        in
        Junk.none
          |> Junk.html html
    , grid = Grid.default
    , area = Area.default
    , line = Line.default
    , dots = Dots.hoverOne (Maybe.map Events.data model.hovered)
    }
    [ LineChart.line Color.orange Dots.triangle "Chuck" chuck
    , LineChart.line Color.yellow Dots.circle "Bobby" bobby
    , LineChart.line Color.purple Dots.diamond "Alice" alice
    ]


tooltip : Info -> Coordinate.System -> Html.Html msg
tooltip info =
  let
    viewValue ( label, value ) =
      Html.p
        [ Html.Attributes.style [ ( "margin", "3px" ) ] ]
        [ Html.text (label ++ " - " ++ toString value) ]
  in
  Junk.hoverCustom
    { position = { x = Just info.age, y = Just info.weight, offset = 15 }
    , styles =
        [ ( "background", "rgba(247, 193, 255, 0.8)" )
        , ( "border", "1px solid #51ff5f" )
        ]
    , content =
        List.map viewValue
          [ ( "age", info.age )
          , ( "weight", info.weight )
          ]
    }



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
  , Info 43 33 1.75 40000
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
