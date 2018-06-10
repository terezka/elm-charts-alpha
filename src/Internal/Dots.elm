module Internal.Dots exposing
  ( Config, default, custom, customAny
  , Shape(..), ShapeOrNone(..)
  , Style, style, empty, disconnected, aura, full
  , Variety
  , Outlier
  , view, viewSample
  )

{-| -}

import Svg exposing (Svg)
import Svg.Attributes as Attributes
import Internal.Coordinate as Coordinate exposing (..)
import Internal.Data as Data
import Color
import Color.Convert



{-| -}
type Config data =
  Config
    { legend : List data -> Style
    , individual : data -> Style
    }


{-| -}
default : Config data
default =
  Config
    { legend = \_ -> disconnected 10 2
    , individual = \_ -> disconnected 10 2
    }


{-| -}
custom : Style -> Config data
custom style =
  Config
    { legend = \_ -> style
    , individual = \_ -> style
    }


{-| -}
customAny :
  { legend : List data -> Style
  , individual : data -> Style
  }
  -> Config data
customAny =
  Config



-- STYLE


{-| -}
type Style =
  Style StyleConfig


{-| -}
type alias StyleConfig =
  { radius : Float
  , variety : Variety
  }


{-| -}
type Variety
  = Empty Int
  | Disconnected Int
  | Aura Int Float
  | Full


{-| -}
type ShapeOrNone =
  ShapeOrNone (Maybe Shape)


{-| -}
type Shape
  = Circle
  | Triangle
  | Square
  | Diamond
  | Cross
  | Plus


{-| -}
style : Float -> Variety -> Style
style radius variety =
  Style
    { radius = radius
    , variety = variety
    }


{-| -}
empty : Float -> Int -> Style
empty radius border =
  style radius (Empty border)


{-| -}
disconnected : Float -> Int -> Style
disconnected radius border =
  style radius (Disconnected border)


{-| -}
aura : Float -> Int -> Float -> Style
aura radius aura opacity =
  style radius (Aura aura opacity)


{-| -}
full : Float -> Style
full radius =
  style radius Full



-- OUTLIERS


{-| -}
type alias Outlier =
  { shape : Shape
  , style : Style
  , color : Color.Color -> Color.Color
  }



-- INTERNAL / VIEW


{-| -}
type alias Arguments data =
  { system : Coordinate.System
  , dotsConfig : Config data
  , outlier : Outlier
  , shape : Maybe Shape
  , color : Color.Color
  }


{-| -}
view : Arguments data -> Data.Data data -> Svg msg
view arguments datum =
  let
    (Config config) =
      arguments.dotsConfig

    (Style style) =
      if datum.isOutlier
        then arguments.outlier.style
        else config.individual datum.user -- TODO

    shape =
      if datum.isOutlier
        then Just arguments.outlier.shape
        else arguments.shape

    color =
      if datum.isOutlier
        then arguments.outlier.color arguments.color
        else arguments.color
  in
  viewShape arguments.system style shape color datum.point


{-| -}
viewSample : Config data -> Maybe Shape -> Color.Color -> Coordinate.System -> List (Data.Data data) -> Coordinate.Point -> Svg msg
viewSample (Config config) shape color system data =
  let
    (Style style) =
       config.legend (List.map .user data)
  in
  viewShape system style shape color



-- INTERNAL / VIEW / PARTS


viewShape : Coordinate.System -> StyleConfig -> Maybe Shape -> Color.Color -> Point -> Svg msg
viewShape system { radius, variety } shape color point =
  let size = 2 * pi * radius
      pointSvg = toSvg system point
      view shape_ =
        case shape_ of
          Circle   -> viewCircle
          Triangle -> viewTriangle
          Square   -> viewSquare
          Diamond  -> viewDiamond
          Cross    -> viewCross
          Plus     -> viewPlus
  in
  case shape of
    Nothing  -> Svg.text ""
    Just shape_ -> view shape_ [] variety color size pointSvg


viewCircle : List (Svg.Attribute msg) -> Variety -> Color.Color -> Float -> Coordinate.Point -> Svg msg
viewCircle events variety color area point =
  let
    radius = sqrt (area / pi)
    attributes =
      [ Attributes.cx (toString point.x)
      , Attributes.cy (toString point.y)
      , Attributes.r (toString radius)
      ]
  in
  Svg.circle (events ++ attributes ++ varietyAttributes color variety) []


viewTriangle : List (Svg.Attribute msg) -> Variety -> Color.Color -> Float -> Coordinate.Point -> Svg msg
viewTriangle events variety color area point =
  let
    attributes =
      [ Attributes.d (pathTriangle area point) ]
  in
  Svg.path (events ++ attributes ++ varietyAttributes color variety) []


viewSquare : List (Svg.Attribute msg) -> Variety -> Color.Color -> Float -> Coordinate.Point -> Svg msg
viewSquare events variety color area point =
  let
    side = sqrt area
    attributes =
      [ Attributes.x <| toString (point.x - side / 2)
      , Attributes.y <| toString (point.y - side / 2)
      , Attributes.width <| toString side
      , Attributes.height <| toString side
      ]
  in
  Svg.rect (events ++ attributes ++ varietyAttributes color variety) []


viewDiamond : List (Svg.Attribute msg) -> Variety -> Color.Color -> Float -> Coordinate.Point -> Svg msg
viewDiamond events variety color area point =
  let
    side = sqrt area
    rotation = "rotate(45 " ++ toString point.x ++ " " ++ toString point.y  ++ ")"
    attributes =
      [ Attributes.x <| toString (point.x - side / 2)
      , Attributes.y <| toString (point.y - side / 2)
      , Attributes.width <| toString side
      , Attributes.height <| toString side
      , Attributes.transform rotation
      ]
  in
  Svg.rect (events ++ attributes ++ varietyAttributes color variety) []


viewPlus : List (Svg.Attribute msg) -> Variety -> Color.Color -> Float -> Coordinate.Point -> Svg msg
viewPlus events variety color area point =
  let
    attributes =
      [ Attributes.d (pathPlus area point) ]
  in
  Svg.path (events ++ attributes ++ varietyAttributes color variety) []


viewCross : List (Svg.Attribute msg) -> Variety -> Color.Color -> Float -> Coordinate.Point -> Svg msg
viewCross events variety color area point =
  let
    rotation = "rotate(45 " ++ toString point.x ++ " " ++ toString point.y  ++ ")"
    attributes =
      [ Attributes.d (pathPlus area point)
      , Attributes.transform rotation
      ]
  in
  Svg.path (events ++ attributes ++ varietyAttributes color variety) []



-- INTERNAL / PATHS


pathTriangle : Float -> Point -> String
pathTriangle area point =
  let
    side = sqrt <| area * 4 / (sqrt 3)
    height = (sqrt 3) * side / 2
    fromMiddle = height - tan (degrees 30) * side / 2

    commands =
      [ "M" ++ toString point.x ++ " " ++ toString (point.y - fromMiddle)
      , "l" ++ toString (-side / 2) ++ " " ++ toString height
      , "h" ++ toString side
      , "z"
      ]
  in
  String.join " " commands


pathPlus : Float -> Point -> String
pathPlus area point =
  let
    side = sqrt (area / 5)
    r3 = side
    r6 = side / 2

    commands =
      [ "M" ++ toString (point.x - r6) ++ " " ++ toString (point.y - r3 - r6)
      , "v" ++ toString r3
      , "h" ++ toString -r3
      , "v" ++ toString r3
      , "h" ++ toString r3
      , "v" ++ toString r3
      , "h" ++ toString r3
      , "v" ++ toString -r3
      , "h" ++ toString r3
      , "v" ++ toString -r3
      , "h" ++ toString -r3
      , "v" ++ toString -r3
      , "h" ++ toString -r3
      , "v" ++ toString r3
      ]
  in
  String.join " " commands



-- INTERNAL / STYLE ATTRIBUTES


varietyAttributes : Color.Color -> Variety -> List (Svg.Attribute msg)
varietyAttributes color variety =
  case variety of
    Empty width ->
      [ Attributes.stroke (Color.Convert.colorToHex color)
      , Attributes.strokeWidth (toString width)
      , Attributes.fill "white"
      ]

    Aura width opacity ->
      [ Attributes.stroke (Color.Convert.colorToHex color)
      , Attributes.strokeWidth (toString width)
      , Attributes.strokeOpacity (toString opacity)
      , Attributes.fill (Color.Convert.colorToHex color)
      ]

    Disconnected width ->
      [ Attributes.stroke "white"
      , Attributes.strokeWidth (toString width)
      , Attributes.fill (Color.Convert.colorToHex color)
      ]

    Full ->
      [ Attributes.fill (Color.Convert.colorToHex color) ]
