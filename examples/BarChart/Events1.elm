module Events1 exposing (main)

import Html
import Html.Attributes
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
    { hovering : Maybe (Events.Found Data) }


init : Model
init =
    { hovering = Nothing }



-- UPDATE


type Msg
  = Hover (Maybe (Events.Found Data))


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
    { independentAxis = IndependentAxis.default 700 "quarter" .label -- TODO customize label?
    , dependentAxis = DependentAxis.default 400 "$" -- TODO negative labels -- TODO horizontal border radius
    , container = Container.default "bar-chart"
    , orientation = Orientation.default
    , legends = Legends.default
    , events = Events.hoverOne Hover
    , grid = Grid.none
    , bars = Bars.custom (Bars.Properties Nothing 100 2) -- TODO set y on hover
    , junk = Junk.hoverOne model.hovering [ ( "ok", toString << .magnesium ) ]
    , pattern = Pattern.default
    }
    [ indonesia model.hovering, malaysia, vietnam ]
    data


indonesia : Maybe (Events.Found Data) -> BarChart.Series Data
indonesia hovering =
  BarChart.series
    { title = "Indonesia"
    , style =
        { base = { fill = Color.rgba 245 105 215 0.5, border = Color.rgba 245 105 215 1 }
        , emphasized = \datum ->
            if Maybe.map Events.data hovering == Just datum then
              { fill = Color.rgba 245 105 215 0.7, border = Color.rgba 245 105 215 1 }
            else
              { fill = Color.rgba 245 105 215 0.5, border = Color.rgba 245 105 215 1 }
        }
    , variable = .magnesium
    , pattern = False
    }


malaysia : BarChart.Series Data
malaysia =
  BarChart.series
    { title = "Malaysia"
    , style =
        { base = { fill = Color.rgba 0 229 255 0.4, border = Color.rgba 0 229 255 1 }
        , emphasized = \_ -> { fill = Color.rgba 0 229 255 0.4, border = Color.rgba 0 229 255 1 }
        }
    , variable = .heartattacks
    , pattern = False
    }


vietnam : BarChart.Series Data
vietnam =
  BarChart.series
    { title = "Vietnam"
    , style =
        { base = { fill = Color.rgba 3 169 244 0.5, border = Color.rgba 3 169 244 1 }
        , emphasized = \_ -> { fill = Color.rgba 3 169 244 0.5, border = Color.rgba 3 169 244 1 }
        }
    , variable = .heartattacks
    , pattern = False
    }




-- DATA


type alias Data =
  { magnesium : Float
  , expected : Float
  , heartattacks : Float
  , label : String
  }


data : List Data
data =
  [ Data 1 5 -2 "1st"
  , Data 2 6 3 "2nd"
  , Data 3 7 6 "3rd"
  , Data 4 8 3 "4th"
  ]
