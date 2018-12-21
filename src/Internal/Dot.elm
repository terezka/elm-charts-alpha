module Internal.Dot exposing
  ( Config, default, custom, customAny
  , Series, series, label, data, color
  , Shape(..)
  , Style, style, empty, disconnected, aura, full
  , Variety
  , viewForLines, viewForScatter, viewSample, viewMany, viewSampleForScatter
  )

{-| -}

import Svg exposing (Svg)
import Svg.Attributes as Attributes
import Internal.Coordinate as Coordinate exposing (..)
import Internal.Point as Point
import Internal.Element as Element
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
custom style_ =
  Config
    { legend = \_ -> style_
    , individual = \_ -> style_
    }


{-| -}
customAny :
  { legend : List data -> Style
  , individual : data -> Style
  }
  -> Config data
customAny =
  Config



-- SERIES


{-| -}
type Series data
  = Series (SeriesConfig data)


{-| -}
type alias SeriesConfig data =
  { color : Color.Color
  , shape : Shape
  , label : String
  , data : List data
  }


{-| -}
series : Color.Color -> Shape -> String -> List data -> Series data
series color_ shape label_ data_ =
  Series (SeriesConfig color_ shape label_ data_)


{-| -}
label : Series data -> String
label (Series series_) =
  series_.label


{-| -}
data : Series data -> List data
data (Series series_) =
  series_.data


{-| -}
color : Series data -> Color.Color
color (Series series_) =
  series_.color



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
aura radius aura_ opacity =
  style radius (Aura aura_ opacity)


{-| -}
full : Float -> Style
full radius =
  style radius Full



-- INTERNAL / VIEW


{-| -}
type alias Arguments data =
  { system : Coordinate.System
  , dotsConfig : Config data
  , shape : Maybe Shape
  , color : Color.Color
  }


{-| -}
viewForLines : Arguments data -> Point.Point Element.LineDot data -> Svg msg
viewForLines arguments point =
  let
    (Config config) =
      arguments.dotsConfig

    (Style style_) =
      config.individual point.source
  in
  viewShape arguments.system style_ arguments.shape arguments.color point.coordinates


{-| -}
viewForScatter : Arguments data -> Point.Point Element.Dot data -> Svg msg
viewForScatter arguments point =
  let
    (Config config) =
      arguments.dotsConfig

    (Style style_) =
      config.individual point.source -- TODO

    shape =
      arguments.shape

    color_ =
      arguments.color
  in
  viewShape arguments.system style_ shape color_ point.coordinates


{-| -}
viewSample : Config data -> Maybe Shape -> Color.Color -> Coordinate.System -> List (Point.Point element data) -> Coordinate.Point -> Svg msg
viewSample (Config config) shape color_ system data_ =
  let
    (Style style_) =
       config.legend (List.map .source data_)
  in
  viewShape system style_ shape color_



-- INTERNAL / VIEW / MANY


{-| -}
viewMany : Config data -> Coordinate.System -> List (Series data) -> List (List (Point.Point Element.Dot data)) -> Svg.Svg msg
viewMany dotsConfig system series__ points =
  let
    view_ series_ points_ =
      let visible = List.filter (Coordinate.isWithinRange system << .coordinates) points_
      in Svg.g [ Attributes.class "chart__group" ] (List.map (viewDot series_) visible)

    viewDot (Series series_) =
      viewForScatter
        { system = system
        , dotsConfig = dotsConfig
        , shape = Just series_.shape
        , color = series_.color
        }
  in
  Svg.g
    [ Attributes.class "chart__groups" ]
    (List.map2 view_ series__ points)


viewSampleForScatter : Config data -> Coordinate.System -> Series data -> List (Point.Point Element.Dot data) -> Float -> Svg.Svg msg
viewSampleForScatter dotsConfig system (Series series_) data_ sampleWidth =
  let
    dotPosition =
      Coordinate.Point (sampleWidth / 2) 0
        |> Coordinate.toData system
  in
  Svg.g
    [ Attributes.class "chart__sample" ]
    [ viewSample dotsConfig (Just series_.shape) series_.color system data_ dotPosition
    ]



-- INTERNAL / VIEW / PARTS


viewShape : Coordinate.System -> StyleConfig -> Maybe Shape -> Color.Color -> Point -> Svg msg
viewShape system { radius, variety } shape color_ point =
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
    Just shape_ -> view shape_ [] variety color_ size pointSvg


viewCircle : List (Svg.Attribute msg) -> Variety -> Color.Color -> Float -> Coordinate.Point -> Svg msg
viewCircle events variety color_ area point =
  let
    radius = sqrt (area / pi)
    attributes =
      [ Attributes.cx (String.fromFloat point.x)
      , Attributes.cy (String.fromFloat point.y)
      , Attributes.r (String.fromFloat radius)
      ]
  in
  Svg.circle (events ++ attributes ++ varietyAttributes color_ variety) []


viewTriangle : List (Svg.Attribute msg) -> Variety -> Color.Color -> Float -> Coordinate.Point -> Svg msg
viewTriangle events variety color_ area point =
  let
    attributes =
      [ Attributes.d (pathTriangle area point) ]
  in
  Svg.path (events ++ attributes ++ varietyAttributes color_ variety) []


viewSquare : List (Svg.Attribute msg) -> Variety -> Color.Color -> Float -> Coordinate.Point -> Svg msg
viewSquare events variety color_ area point =
  let
    side = sqrt area
    attributes =
      [ Attributes.x <| String.fromFloat (point.x - side / 2)
      , Attributes.y <| String.fromFloat (point.y - side / 2)
      , Attributes.width <| String.fromFloat side
      , Attributes.height <| String.fromFloat side
      ]
  in
  Svg.rect (events ++ attributes ++ varietyAttributes color_ variety) []


viewDiamond : List (Svg.Attribute msg) -> Variety -> Color.Color -> Float -> Coordinate.Point -> Svg msg
viewDiamond events variety color_ area point =
  let
    side = sqrt area
    rotation = "rotate(45 " ++ String.fromFloat point.x ++ " " ++ String.fromFloat point.y  ++ ")"
    attributes =
      [ Attributes.x <| String.fromFloat (point.x - side / 2)
      , Attributes.y <| String.fromFloat (point.y - side / 2)
      , Attributes.width <| String.fromFloat side
      , Attributes.height <| String.fromFloat side
      , Attributes.transform rotation
      ]
  in
  Svg.rect (events ++ attributes ++ varietyAttributes color_ variety) []


viewPlus : List (Svg.Attribute msg) -> Variety -> Color.Color -> Float -> Coordinate.Point -> Svg msg
viewPlus events variety color_ area point =
  let
    attributes =
      [ Attributes.d (pathPlus area point) ]
  in
  Svg.path (events ++ attributes ++ varietyAttributes color_ variety) []


viewCross : List (Svg.Attribute msg) -> Variety -> Color.Color -> Float -> Coordinate.Point -> Svg msg
viewCross events variety color_ area point =
  let
    rotation = "rotate(45 " ++ String.fromFloat point.x ++ " " ++ String.fromFloat point.y  ++ ")"
    attributes =
      [ Attributes.d (pathPlus area point)
      , Attributes.transform rotation
      ]
  in
  Svg.path (events ++ attributes ++ varietyAttributes color_ variety) []



-- INTERNAL / PATHS


pathTriangle : Float -> Point -> String
pathTriangle area point =
  let
    side = sqrt <| area * 4 / (sqrt 3)
    height = (sqrt 3) * side / 2
    fromMiddle = height - tan (degrees 30) * side / 2

    commands =
      [ "M" ++ String.fromFloat point.x ++ " " ++ String.fromFloat (point.y - fromMiddle)
      , "l" ++ String.fromFloat (-side / 2) ++ " " ++ String.fromFloat height
      , "h" ++ String.fromFloat side
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
      [ "M" ++ String.fromFloat (point.x - r6) ++ " " ++ String.fromFloat (point.y - r3 - r6)
      , "v" ++ String.fromFloat r3
      , "h" ++ String.fromFloat -r3
      , "v" ++ String.fromFloat r3
      , "h" ++ String.fromFloat r3
      , "v" ++ String.fromFloat r3
      , "h" ++ String.fromFloat r3
      , "v" ++ String.fromFloat -r3
      , "h" ++ String.fromFloat r3
      , "v" ++ String.fromFloat -r3
      , "h" ++ String.fromFloat -r3
      , "v" ++ String.fromFloat -r3
      , "h" ++ String.fromFloat -r3
      , "v" ++ String.fromFloat r3
      ]
  in
  String.join " " commands



-- INTERNAL / STYLE ATTRIBUTES


varietyAttributes : Color.Color -> Variety -> List (Svg.Attribute msg)
varietyAttributes color_ variety =
  case variety of
    Empty width ->
      [ Attributes.stroke (Color.Convert.colorToCssRgba color_)
      , Attributes.strokeWidth (String.fromInt width)
      , Attributes.fill "white"
      ]

    Aura width opacity ->
      [ Attributes.stroke (Color.Convert.colorToCssRgba color_)
      , Attributes.strokeWidth (String.fromInt width)
      , Attributes.strokeOpacity (String.fromFloat opacity)
      , Attributes.fill (Color.Convert.colorToCssRgba color_)
      ]

    Disconnected width ->
      [ Attributes.stroke "white"
      , Attributes.strokeWidth (String.fromInt width)
      , Attributes.fill (Color.Convert.colorToCssRgba color_)
      ]

    Full ->
      [ Attributes.fill (Color.Convert.colorToCssRgba color_) ]
