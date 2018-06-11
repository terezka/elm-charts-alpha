module BarsExample exposing (main)


import Html
import Html.Attributes
import Svg exposing (Svg, Attribute, g, text, text_)
import Svg.Attributes exposing (style)
import BarChart
import BarChart.Axis.Independent as IndependentAxis
import BarChart.Axis.Dependent as DependentAxis
import BarChart.Orientation as Orientation
import BarChart.Legends as Legends
import BarChart.Events as Events
import BarChart.Container as Container
import BarChart.Grid as Grid
import BarChart.Bars as Bars
import BarChart.Junk as Junk
import BarChart.Pattern as Pattern
import BarChart.Colors as Colors
import Color


main : Html.Html msg
main =
  Html.div
    [ Html.Attributes.style [ ( "font-family", "monospace" ) ] ]
    [ chart ]


chart : Html.Html msg
chart =
  BarChart.view -- TODO should pixels be defined elsewhere due to orientation switching?
    { independentAxis = IndependentAxis.default 700 "gender" .label
    , dependentAxis = DependentAxis.default 400 "magnesium"
    , container = Container.default "bar-chart"
    , orientation = Orientation.default
    , legends = Legends.default
    , events = Events.default
    , grid = Grid.default
    , bars = Bars.default
    , junk = Junk.default
    , pattern = Pattern.default
    }
    [ BarChart.barWithExpectation (always (Color.rgba 255 204 128 0.8)) [] .magnesium .expected
    , BarChart.bar (always (Color.rgba 128 203 196 0.6)) [] .heartattacks
    ]
    data


label : Float -> Bars.Label msg
label =
  Bars.Label [ style "font-size: 14px;" ] 20 -5 << toString


barColor : Data -> Color.Color
barColor data =
  if data.label == "Trans" then
    Colors.blueLight
  else
    Colors.pink


{-| -}
defaultLabel : String -> Svg msg
defaultLabel position =
  Svg.text_ [] [ Svg.tspan [] [ Svg.text position ] ]

{-| -}
defaultValueLabel : Data -> Svg msg
defaultValueLabel data =
  Svg.text_ [] [ Svg.tspan [] [ Svg.text (toString data.magnesium) ] ]



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
