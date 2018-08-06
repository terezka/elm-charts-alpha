module Examples.BarChart.Events1 exposing (main)

import Html
import Html.Attributes
import Chart.Axis.Independent
import Chart.Axis.Dependent
import Chart.Axis.Unit
import Chart.Orientation
import Chart.Legends
import Chart.Events
import Chart.Container
import Chart.Events
import Chart.Grid
import Chart.Block
import Chart.Junk
import Chart.Pattern
import Chart.Colors as Colors
import Blocks
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


main : Program Never Model Msg
main =
  Html.beginnerProgram
    { model = init
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
    [ Html.Attributes.style [ ( "font-family", "monospace" ) ] ]
    [ chart model ]


chart : Model -> Html.Html Msg
chart model =
  Blocks.view .label [ denmark, norway, sweden, iceland ] data
    

denmark : Blocks.Series Data
denmark =
  Blocks.series
    { title = "Denmark"
    , style = Blocks.bordered Colors.pinkLight Colors.pink
    , variable = .denmark
    , pattern = False
    }

norway : Blocks.Series Data
norway =
  Blocks.series
    { title = "Norway"
    , style = Blocks.bordered Colors.blueLight Colors.blue 
    , variable = .norway
    , pattern = False
    }


sweden : Blocks.Series Data
sweden =
  Blocks.series
    { title = "Sweden"
    , style = Blocks.bordered Colors.cyanLight Colors.cyan
    , variable = .sweden
    , pattern = False
    }


iceland : Blocks.Series Data
iceland =
  Blocks.series
    { title = "Iceland"
    , style = Blocks.bordered Colors.goldLight Colors.gold
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
  [ Data 1 5 2 4 "1"
  , Data 2 6 3 4 "2"
  , Data 3 7 6 4 "3"
  , Data 4 8 3 4 "4"
  ]
