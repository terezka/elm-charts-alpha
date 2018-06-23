module Events1 exposing (main)

import Html
import Html.Attributes
import Svg exposing (Svg, Attribute, g, text, text_)
import BarChart
import BarChart.Axis.Independent as IndependentAxis
import BarChart.Axis.Dependent as DependentAxis
import BarChart.Orientation as Orientation
import BarChart.Legends as Legends
import BarChart.Events as Events
import BarChart.Container as Container
import BarChart.Events as Events
import BarChart.Grid as Grid
import BarChart.Bars as Bars
import BarChart.Junk as Junk
import BarChart.Colors as Colors
import BarChart.Pattern as Pattern
import BarChart.Coordinate as Coordinate
import Internal.Junk
-- TODO ^^^^
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
    { hovering : List Data }


init : Model
init =
    { hovering = [] }



-- UPDATE


type Msg
  = Hover (List Data)


update : Msg -> Model -> Model
update msg model =
  case msg of
    Hover hovering ->
      { model | hovering = hovering }



-- VIEW


view : Model -> Html.Html Msg
view model =
  Html.div
    [ Html.Attributes.style [ ( "font-family", "monospace" ) ] ]
    [ chart model ]



chart : Model -> Html.Html Msg
chart model =
  BarChart.view -- TODO should pixels be defined elsewhere due to orientation switching?
    { independentAxis = IndependentAxis.default 700 "gender" .label -- TODO customize label?
    , dependentAxis = DependentAxis.default 400 "$" -- TODO negative labels
    , container = Container.default "bar-chart"
    , orientation = Orientation.default
    , legends = Legends.default
    , events =
        Events.custom
          [ Events.onMouseMove Hover (Events.getNearestX)
          , Events.on "touchstart" Hover (Events.getNearestX)
          , Events.on "touchmove" Hover (Events.getNearestX)
          , Events.onMouseLeave (Hover [])
          ]
    , grid = Grid.default
    , bars = Bars.default
    , junk = Junk.hoverMany model.hovering .label (toString << .magnesium)
    , pattern = Pattern.default
    }
    [ BarChart.bar "Indonesia" (always (Color.rgba 255 204 128 0.8)) [] .magnesium
    , BarChart.bar "Malaysia" (always Colors.blueLight) [] .heartattacks
    ]
    data


-- DATA


type alias Data =
  { magnesium : Float
  , expected : Float
  , heartattacks : Float
  , label : String
  }


data : List Data
data =
  [ Data 1 5 8 "Female"
  , Data 2 6 3 "Male"
  , Data 3 7 6 "Trans"
  , Data 4 8 3 "Fluid"
  ]
