module Internal.Bars exposing (Config, default, custom, Bar, bar, barWithExpectation, barConfigs, toGroups, viewGroup)

{-| -}

import Svg
import Svg.Attributes
import Color
import BarChart.Junk as Junk
import Internal.Coordinate as Coordinate
import Internal.Orientation as Orientation
import Internal.Svg as Svg
import Internal.Path as Path
import Internal.Utils as Utils
import Color.Convert


{-| -}
type Config msg =
  Config (Properties msg)


{-| -}
type alias Properties msg =
  { label : Maybe (Float -> Label msg)
  , width : Float
  , borderRadius : Int
  }


{-| -}
type alias Label msg =
  { attributes : List (Svg.Attribute msg)
  , xOffset : Float
  , yOffset : Float
  , text : String
  }


{-| -}
default : Config msg
default =
  custom
    { label = Just defaultLabel
    , width = 100
    , borderRadius = 5
    }


defaultLabel : Float -> Label msg
defaultLabel n =
  { attributes = []
  , xOffset = 0
  , yOffset = 0
  , text = toString n
  }


{-| -}
custom : Properties msg -> Config msg
custom =
  Config



-- BAR


{-| -}
type Bar data msg =
  Bar (BarConfig data msg)


{-| -}
bar : (data -> Color.Color) -> List (Svg.Attribute msg) -> (data -> Float) -> Bar data msg
bar color attributes variable =
  Bar <| BarConfig color attributes variable Nothing


{-| -}
barWithExpectation : (data -> Color.Color) -> List (Svg.Attribute msg) -> (data -> Float) -> (data -> Float) -> Bar data msg
barWithExpectation color attributes variable expectation =
  Bar <| BarConfig color attributes variable (Just expectation)



-- INTERNAL


type alias BarConfig data msg =
  { color : data -> Color.Color
  , attributes : List (Svg.Attribute msg)
  , variable : data -> Float
  , expectation : Maybe (data -> Float)
  }


{-| -}
barConfigs : Bar data msg -> List (BarConfig data msg)
barConfigs (Bar config) =
  case config.expectation of
    Just expectation ->
      [ config, BarConfig config.color (addMask config.attributes) expectation Nothing  ]

    Nothing ->
      [ config ]


addMask : List (Svg.Attribute msg) -> List (Svg.Attribute msg)
addMask attributes =
  attributes ++ [ Svg.Attributes.mask "url(#mask-stripe)" ]



-- INTERNAL / GROUP


type alias BarInfo msg =
  { point : Coordinate.Point
  , attributes : List (Svg.Attribute msg)
  , index : Int
  , color : Color.Color
  , label : Maybe (Label msg)
  }


toGroups : Orientation.Config -> Config msg -> List (BarConfig data msg) -> List data -> List (List (BarInfo msg))
toGroups orientation (Config config) barsConfigs data =
  let
    groupInfo groupIndex datum =
      List.indexedMap (barInfo groupIndex datum) barsConfigs

    barInfo groupIndex datum index bar =
      { point = point (bar.variable datum) (toFloat groupIndex + 1)
      , attributes = bar.attributes
      , index = index
      , color = bar.color datum
      , label = Maybe.map (\v -> v (bar.variable datum)) config.label
      }

    point value position =
      case orientation of
        Orientation.Horizontal ->
          Coordinate.Point value position

        Orientation.Vertical ->
          Coordinate.Point position value
  in
  List.indexedMap groupInfo data


viewGroup : Orientation.Config -> Config msg -> Coordinate.System -> Int -> Int -> List (BarInfo msg) -> Svg.Svg msg
viewGroup orientation config system totalOfGroups totalOfBars group =
  let
    viewBar =
      case orientation of
        Orientation.Horizontal ->
          viewBarHorizontal

        Orientation.Vertical ->
          viewBarVertical
  in
  Svg.g [ Svg.Attributes.class "group" ] (List.map (viewBar config system totalOfGroups totalOfBars) group)


viewBarHorizontal : Config msg -> Coordinate.System -> Int -> Int -> BarInfo msg -> Svg.Svg msg
viewBarHorizontal (Config config) system totalOfGroups totalOfBars { point, index, color, label, attributes } =
  let
    offset =
      barOffset index totalOfBars

    maxWidth =
      (Coordinate.lengthY system) / (toFloat totalOfGroups) / (toFloat totalOfBars)

    width =
      config.width / (toFloat totalOfBars)
        |> Basics.min maxWidth
        |> Coordinate.scaleDataY system

    y =
      point.y - width * offset

    x =
      point.x

    commands =
      Svg.horizontalBarCommands system config.borderRadius width (Coordinate.Point x y)

    viewLabel label =
      Junk.labelAt system x (y - width / 2) (label.xOffset + 10) (label.yOffset + 3) "middle" Color.black label.text
  in
  Svg.g
    [ Svg.Attributes.class "bar" ]
    [ Path.view system (attributes ++ [ Svg.Attributes.fill (Color.Convert.colorToHex color) ]) commands
    , Utils.viewMaybe label viewLabel
    ]


viewBarVertical : Config msg -> Coordinate.System -> Int -> Int -> BarInfo msg -> Svg.Svg msg
viewBarVertical (Config config) system totalOfGroups totalOfBars { point, index, color, label, attributes } =
  let
    offset =
      barOffset index totalOfBars

    maxWidth =
      (Coordinate.lengthX system) / (toFloat totalOfGroups) / (toFloat totalOfBars)

    width =
      config.width / (toFloat totalOfBars)
        |> Basics.min maxWidth
        |> Coordinate.scaleDataX system

    x =
      point.x + width * offset

    y =
      point.y

    commands =
      Svg.verticalBarCommands system config.borderRadius width (Coordinate.Point x y)

    viewLabel label =
      Junk.labelAt system (x + width / 2) y label.xOffset (label.yOffset - 5) "middle" Color.black label.text
  in
  Svg.g
    [ Svg.Attributes.class "bar" ]
    [ Path.view system (attributes ++ [ Svg.Attributes.fill (Color.Convert.colorToHex color) ]) commands
    , Utils.viewMaybe label viewLabel
    ]


barOffset : Int -> Int -> Float
barOffset index totalOfBars =
  toFloat index - (toFloat totalOfBars / 2)


