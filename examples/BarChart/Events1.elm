module Events1 exposing (main)

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
import Chart.Blocks
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
-- collapse everything <---
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
  Chart.Blocks.view
    { independentAxis = Chart.Axis.Independent.default "quarter" .label
    , dependentAxis = Chart.Axis.Dependent.default "income" Chart.Axis.Unit.dollars
    , container = Chart.Container.default "bar-chart" 700 400
    , orientation = Chart.Orientation.default
    , legends = Chart.Legends.default
    , events = Chart.Events.hoverBlocks Hover
    , grid = Chart.Grid.none
    , bars = Chart.Block.custom 2 100
    , junk = Chart.Junk.tooltipForBlocks model.hovering
    , pattern = Chart.Pattern.default
    }
    [ indonesia
    , malaysia
    , vietnam
    ]
    data




indonesia : Chart.Blocks.Series Data
indonesia =
  Chart.Blocks.series
    { title = "Indonesia"
    , style = Chart.Blocks.bordered (Color.rgba 245 105 215 0.5) (Color.rgba 245 105 215 1)
    , variable = .indonesia
    , pattern = True
    }


malaysia : Chart.Blocks.Series Data
malaysia =
  Chart.Blocks.series
    { title = "Malaysia"
    , style = Chart.Blocks.bordered (Color.rgba 0 229 255 0.5) (Color.rgba 0 229 255 1)
    , variable = .malaysia
    , pattern = False
    }


vietnam : Chart.Blocks.Series Data
vietnam =
  Chart.Blocks.series
    { title = "Vietnam"
    , style = Chart.Blocks.bordered (Color.rgba 3 169 244 0.5) (Color.rgba 3 169 244 1)
    , variable = .vietnam
    , pattern = False
    }



-- DATA


type alias Data =
  { indonesia : Float
  , vietnam : Float
  , malaysia : Float
  , label : String
  }


data : List Data
data =
  [ Data 1 5 2 "1st"
  , Data 2 6 3 "2nd"
  , Data 3 7 6 "3rd"
  , Data 4 8 3 "4th"
  ]
