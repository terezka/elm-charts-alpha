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
import Internal.Data as Data
import Internal.Group as Group
import Internal.Utils as Utils



{-| -}
type Config data
  = None
  | Single Color.Color (Width data) Function Bool
  | Individual (Color.Color -> Color.Color) (Width data) Function Bool


type alias Width data =
  List data -> Float


{-| -}
default : Config data
default =
  None


{-| -}
single : Color.Color -> Config data
single color =
  Single color (always 1) linear True


{-| -}
singleCustom : Color.Color -> (List data -> Float) -> Function -> Bool -> Config data
singleCustom =
  Single


{-| -}
individual : Config data
individual =
  Individual identity (always 1) linear True


{-| -}
individualCustom : (Color.Color -> Color.Color) -> (List data -> Float) -> Function -> Bool -> Config data
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
view : Coordinate.System -> Config data -> Group.Config data -> List (Group.Group data) -> List (List (Data.Data data)) -> Svg.Svg msg
view system config groupConfig groups data =
  case config of
    None ->
      Svg.text ""

    Single color width function includeOutliers ->
      viewSingle system color function width includeOutliers (List.concat data)

    Individual toColor width function includeOutliers ->
      let
        viewSingle_ group data =
          let color = Group.color groupConfig group data in
          viewSingle system (toColor color) function width includeOutliers data

        viewTrends =
          List.map2 viewSingle_ groups data
      in
      Svg.g [ Svg.Attributes.class "chart__trends" ] viewTrends


viewSingle : Coordinate.System -> Color.Color -> Function -> Width data -> Bool -> List (Data.Data data) -> Svg.Svg msg
viewSingle system color function editWidth includeOutliers dataRaw =
  let
    data =
      if includeOutliers
        then dataRaw
        else List.filter (not << .isOutlier) dataRaw

    dataTuples = List.map Data.asTuple data
    dataUser = List.map .user data

    y = function dataTuples
    range = Coordinate.range Tuple.first dataTuples
    width = editWidth dataUser
    xs = resolution system range
    toPoint x = { x = x, y = y x }

    attributes =
      [ Svg.Attributes.stroke (Color.Convert.colorToHex color)
      , Svg.Attributes.strokeWidth (toString width)
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
