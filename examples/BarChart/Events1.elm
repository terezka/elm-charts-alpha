module Examples.BarChart.Events1 exposing (main)

import Browser
import Html
import Html.Attributes
import BarChart
import Chart.Axis.Independent as IndependentAxis
import Chart.Axis.Dependent as DependentAxis
import Chart.Orientation as Orientation
import Chart.Legends as Legends
import Chart.Events as Events
import Chart.Container as Container
import Chart.Grid as Grid
import Chart.Block as Block
import Chart.Junk as Junk
import Chart.Pattern as Pattern
import Chart.Colors as Colors
import Chart.Events
import Chart.Axis.Unit
import Chart.Element as Element
import Color


-- TODO
-- tooltip arrow
-- style api
-- hover stuff for bar chart
-- legend api
-- source
-- notes
-- chart title
-- unit in axis title
-- dashed grid


-- TODO / INTERNAL
-- SVG api
-- review outliers


main =
  Browser.sandbox
    { init = init
    , update = update
    , view = view
    }



-- MODEL


type alias Model =
    { hovering : List (Chart.Events.Found Element.Block Data) }



init : Model
init =
    { hovering = [] }



-- UPDATE


type Msg
  = Hover (List (Chart.Events.Found Element.Block Data))


update : Msg -> Model -> Model
update msg model =
  case msg of
    Hover hovering ->
      { model | hovering = hovering }



-- VIEW


view : Model -> Html.Html Msg
view model =
  Html.div
    [ Html.Attributes.style "font-family" "monospace" ]
    [ chart model ]


chart : Model -> Html.Html Msg
chart model =
  BarChart.viewCustom -- TODO should pixels be defined elsewhere due to orientation switching?
    { independentAxis = IndependentAxis.default "year" .label -- TODO customize label?
    , dependentAxis = DependentAxis.default "GDP" Chart.Axis.Unit.dollars
    , container = Container.default "bar-chart" 700 400
    , orientation = Orientation.default
    , legends = Legends.default
    , events = Events.hoverBlocks Hover
    , grid = Grid.default
    , block = Block.default
    , junk = Junk.hoverBlocks model.hovering
    , pattern = Pattern.default
    }
    [ denmark, norway, sweden, iceland ]
    data


denmark : BarChart.Series Data
denmark =
  BarChart.series
    { title = "Denmark"
    , style = BarChart.bordered Colors.pinkLight Colors.pink
    , variable = .denmark
    , pattern = False
    }

norway : BarChart.Series Data
norway =
  BarChart.series
    { title = "Norway"
    , style = BarChart.bordered Colors.blueLight Colors.blue
    , variable = .norway
    , pattern = False
    }


sweden : BarChart.Series Data
sweden =
  BarChart.series
    { title = "Sweden"
    , style = BarChart.bordered Colors.cyanLight Colors.cyan
    , variable = .sweden
    , pattern = False
    }


iceland : BarChart.Series Data
iceland =
  BarChart.series
    { title = "Iceland"
    , style = BarChart.bordered Colors.goldLight Colors.gold
    , variable = .iceland
    , pattern = False
    }



-- DATA


type alias Data =
  { denmark : Float
  , norway : Float
  , sweden : Float
  , iceland : Float
  , label : String
  }


data : List Data
data =
  [ Data 1 5 2 4 "2016"
  , Data 2 6 3 4 "2017"
  , Data 3 7 6 4 "2018"
  , Data 4 8 3 4 "2019"
  ]
