module Internal.Trend
  exposing
    ( Config
    , default
    , single
    , singleCustom
    , individual
    , individualCustom
    , linear
    -- INTERNAL
    , view
    )


import Svg
import Svg.Attributes
import Color
import Color.Convert
import Trend.Linear as Trend

import Internal.Colors as Colors
import Internal.Coordinate as Coordinate
import Internal.Svg as Svg
import Internal.Path as Path
import Internal.Point as Point
import Internal.Element as Element
import Internal.Dot as Dot
import Internal.Utils as Utils



{-| -}
type Config data
  = None
  | Single Color.Color (Width data) Function
  | Individual (Color.Color -> Color.Color) (Width data) Function


type alias Width data =
  List data -> Float


{-| -}
default : Config data
default =
  None


{-| -}
single : Color.Color -> Config data
single color =
  Single color (always 1) linear


{-| -}
singleCustom : Color.Color -> (List data -> Float) -> Function -> Config data
singleCustom =
  Single


{-| -}
individual : Config data
individual =
  Individual identity (always 1) linear


{-| -}
individualCustom : (Color.Color -> Color.Color) -> (List data -> Float) -> Function -> Config data
individualCustom =
  Individual



-- FUNCTIONS


{-| -}
type alias Function =
  List ( Float, Float ) -> Float -> Float


{-| -}
linear : Function
linear data x =
  let
    trend =
      Trend.quick data
        |> Result.map Trend.line
        |> Result.withDefault (Trend.Line 1 0)
  in
  trend.intercept + trend.slope * x



-- INTERNAL


{-| -}
view : Coordinate.System -> Config data -> List (Dot.Series data) -> List (List (Point.Point Element.Dot data)) -> Svg.Svg msg
view system config series data =
  case config of
    None ->
      Svg.text ""

    Single color width function ->
      viewSingle system color function width (List.concat data)

    Individual toColor width function ->
      let
        viewSingle_ series_ data_ =
          let color = Dot.color series_ in
          viewSingle system (toColor color) function width data_

        viewTrends =
          List.map2 viewSingle_ series data
      in
      Svg.g [ Svg.Attributes.class "chart__trends" ] viewTrends


viewSingle : Coordinate.System -> Color.Color -> Function -> Width data -> List (Point.Point Element.Dot data) -> Svg.Svg msg
viewSingle system color function editWidth data =
  let
    dataTuples = List.map Point.asTuple data
    dataUser = List.map .source data

    y = function dataTuples
    range = Coordinate.range Tuple.first dataTuples
    width = editWidth dataUser
    xs = resolution system range
    toPoint x = { x = x, y = y x }

    attributes =
      [ Svg.Attributes.stroke (Color.Convert.colorToCssRgba color)
      , Svg.Attributes.strokeWidth (String.fromFloat width)
      , Svg.Attributes.fill "transparent"
      , Svg.Attributes.class "chart__trend"
      , Svg.withinChartArea system
      ]
  in
  Path.view system attributes [ Path.Move_ (List.map toPoint xs) ]


resolution : Coordinate.System -> Coordinate.Range -> List Float
resolution system range =
  let is = (range.max - range.min) * system.frame.size.width / (system.x.max - system.x.min)
      res = (range.max - range.min) / is
      x i = range.min + toFloat i * res
  in
  List.map x (List.range 0 (ceiling is))
