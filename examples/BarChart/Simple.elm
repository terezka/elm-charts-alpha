module BlockExample exposing (main)


import Html
import Html.Attributes
import Svg exposing (Svg, Attribute, g, text, text_)
import Svg.Attributes exposing (style)
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
import Chart.Axis.Unit
import Color


main : Html.Html msg
main =
  Html.div
    [ Html.Attributes.style "font-family" "monospace" ]
    [ chart ]


chart : Html.Html msg
chart =
  BarChart.viewCustom -- TODO should pixels be defined elsewhere due to orientation switching?
    { independentAxis = IndependentAxis.default "gender" .label -- TODO customize label?
    , dependentAxis = DependentAxis.default  "magnesium" Chart.Axis.Unit.dollars
    , container = Container.default "bar-chart" 700 400
    , orientation = Orientation.default
    , legends = Legends.default
    , events = Events.default
    , grid = Grid.default
    , block = Block.default
    , junk = Junk.default
    , pattern = Pattern.default
    }
    [ BarChart.series
        { title = "Serie 1"
        , style = BarChart.solid Colors.blue
        , variable = .magnesium
        , pattern = False
        }
    , BarChart.series
        { title = "Serie 2"
        , style = BarChart.solid Colors.pink
        , variable = .heartattacks
        , pattern = False
        }
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
  [ Data 4 2 8 "Female"
  , Data 2 2 3 "Male"
  , Data 3 4 6 "Trans"
  , Data 9 8 3 "Fluid"
  ]
