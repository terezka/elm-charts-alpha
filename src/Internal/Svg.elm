module Internal.Svg exposing
  ( gridDot
  , horizontal, vertical
  , square
  , rectangle
  , horizontalGrid, verticalGrid
  , xTick, yTick
  , label
  , Anchor(..), anchorStyle
  , Transfrom, transform, move, offset
  , withinChartArea
  , horizontalBarCommands
  , verticalBarCommands
  )

{-|

# Lines
@docs horizontal, vertical

# Rectangles
@docs square, rectangle

# Grids

## Dots
@docs gridDot

## Lines
@docs horizontalGrid, verticalGrid

# Axis
@docs xTick, yTick

# Helpers

## Label
@docs label

## Anchor
@docs Anchor, anchorStyle

## Transfrom
@docs Transfrom, transform, move, offset

@docs withinChartArea

@docs horizontalBarCommands, verticalBarCommands

-}

import Svg exposing (Svg, Attribute, g)
import Svg.Attributes as Attributes
import Internal.Colors as Colors
import Internal.Coordinate as Coordinate exposing (..)
import Internal.Path as Path exposing (..)
import Internal.Utils exposing (..)
import Color
import Color.Convert



{-| -}
withinChartArea : Coordinate.System -> Svg.Attribute msg
withinChartArea { id } =
  Attributes.clipPath <| "url(#" ++ toChartAreaId id ++ ")"



-- DOT


{-| -}
square : Float -> Color.Color -> Svg msg
square width color =
  Svg.rect
    [ Attributes.y (toString (-width / 2))
    , Attributes.width (toString width)
    , Attributes.height (toString width)
    , Attributes.fill (Color.Convert.colorToCssRgba color)
    ]
    []


-- DOT


{-| -}
gridDot : Float -> Color.Color -> Point -> Svg msg
gridDot radius color point =
  Svg.circle
    [ Attributes.cx (toString point.x)
    , Attributes.cy (toString point.y)
    , Attributes.r (toString radius)
    , Attributes.fill (Color.Convert.colorToCssRgba color)
    ]
    []



-- AXIS / GRID


{-| -}
horizontal : Coordinate.System -> List (Attribute msg) -> Float -> Float -> Float -> Svg msg
horizontal system userAttributes y x1 x2 =
  let
    attributes =
      concat
        [ Attributes.stroke (Color.Convert.colorToCssRgba Colors.gray)
        , Attributes.style "pointer-events: none;"
        ] userAttributes []
  in
    Path.view system attributes
      [ Move { x = x1, y = y }
      , Line { x = x1, y = y }
      , Line { x = x2, y = y }
      ]


{-| -}
vertical : Coordinate.System -> List (Attribute msg) -> Float -> Float -> Float -> Svg msg
vertical system userAttributes x y1 y2 =
  let
    attributes =
      concat
        [ Attributes.stroke (Color.Convert.colorToCssRgba Colors.gray)
        , Attributes.style "pointer-events: none;"
        ] userAttributes []
  in
    Path.view system attributes
      [ Move { x = x, y = y1 }
      , Line { x = x, y = y1 }
      , Line { x = x, y = y2 }
      ]


{-| -}
rectangle : Coordinate.System -> List (Attribute msg) -> Float -> Float -> Float -> Float -> Svg msg
rectangle system userAttributes x1 x2 y1 y2 =
  let
    attributes =
      concat
        [ Attributes.fill (Color.Convert.colorToCssRgba Colors.gray) ]
        userAttributes []
  in
    Path.view system attributes
      [ Move { x = x1, y = y1 }
      , Line { x = x1, y = y2 }
      , Line { x = x2, y = y2 }
      , Line { x = x2, y = y1 }
      ]


{-| -}
horizontalGrid : Coordinate.System -> List (Attribute msg) -> Float -> Svg msg
horizontalGrid system userAttributes y =
  let
    attributes =
      concat
        [ Attributes.stroke (Color.Convert.colorToCssRgba Colors.gray)
        , Attributes.style "pointer-events: none;"
        ] userAttributes []
  in
  horizontal system attributes y system.x.min system.x.max


{-| -}
verticalGrid : Coordinate.System -> List (Attribute msg) -> Float -> Svg msg
verticalGrid system userAttributes x =
  let
    attributes =
      concat
        [ Attributes.stroke (Color.Convert.colorToCssRgba Colors.gray)
        , Attributes.style "pointer-events: none;"
        ] userAttributes []
  in
  vertical system attributes x system.y.min system.y.max



-- AXIS / TICK


{-| -}
xTick : Coordinate.System -> Float -> List (Attribute msg) -> Float -> Float -> Svg msg
xTick system height userAttributes y x =
  let
    attributes =
      concat
        [ Attributes.stroke (Color.Convert.colorToCssRgba Colors.gray) ]
        userAttributes
        [ Attributes.x1 <| toString (toSvgX system x)
        , Attributes.x2 <| toString (toSvgX system x)
        , Attributes.y1 <| toString (toSvgY system y)
        , Attributes.y2 <| toString (toSvgY system y + height)
        ]
  in
    Svg.line attributes []


{-| -}
yTick : Coordinate.System -> Float -> List (Attribute msg) -> Float -> Float -> Svg msg
yTick system width userAttributes x y =
  let
    attributes =
      concat
        [ Attributes.class "chart__tick"
        , Attributes.stroke (Color.Convert.colorToCssRgba Colors.gray)
        ]
        userAttributes
        [ Attributes.x1 <| toString (toSvgX system x)
        , Attributes.x2 <| toString (toSvgX system x - width)
        , Attributes.y1 <| toString (toSvgY system y)
        , Attributes.y2 <| toString (toSvgY system y)
        ]
  in
    Svg.line attributes []



-- LABEL


{-| -}
label : String -> String -> Svg.Svg msg
label color string =
  Svg.text_
    [ Attributes.fill color
    , Attributes.style "pointer-events: none;"
    ]
    [ Svg.tspan [] [ Svg.text string ] ]


-- ANCHOR


{-| -}
type Anchor
  = Start
  | Middle
  | End


{-| -}
anchorStyle : Anchor -> Svg.Attribute msg
anchorStyle anchor =
  let
    anchorString =
      case anchor of
        Start -> "start"
        Middle -> "middle"
        End -> "end"
  in
  Attributes.style <| "text-anchor: " ++ anchorString ++ ";"



-- TRANSFORM


{-| -}
type Transfrom =
  Transfrom Float Float


{-| -}
move : Coordinate.System -> Float -> Float -> Transfrom
move system x y =
  Transfrom (toSvgX system x) (toSvgY system y)


{-| -}
offset : Float -> Float -> Transfrom
offset x y =
  Transfrom x y


{-| -}
transform : List Transfrom -> Svg.Attribute msg
transform translations =
  let
    (Transfrom x y) =
      toPosition translations
  in
  Attributes.transform <|
    "translate(" ++ toString x ++ ", " ++ toString y ++ ")"


toPosition : List Transfrom -> Transfrom
toPosition =
  List.foldr addPosition (Transfrom 0 0)


addPosition : Transfrom -> Transfrom -> Transfrom
addPosition (Transfrom x y) (Transfrom xf yf) =
  Transfrom (xf + x) (yf + y)



-- BARS


{-| -}
horizontalBarCommands : Coordinate.System -> Int -> Float -> Point -> List Command
horizontalBarCommands system borderRadius width { x, y }  =
  if borderRadius == 0 then
    [ Move <| Point 0 y
    , Line <| Point x y
    , Line <| Point x (y - width)
    , Line <| Point 0 (y - width)
    ]
  else
    if x < 0 then
      let
        b =
          toFloat borderRadius

        rx =
          scaleDataX system b

        ry =
          scaleDataY system b
      in
      [ Move <| Point 0 y
      , Line <| Point (x + rx) y
      , Arc b b -45 False False <| Point x (y - ry)
      , Line <| Point x (y - width + ry)
      , Arc b b 45 False False <| Point (x + rx) (y - width)
      , Line <| Point 0 (y - width)
      ]
    else
      let
        b =
          toFloat borderRadius

        rx =
          scaleDataX system b

        ry =
          scaleDataY system b
      in
      [ Move <| Point 0 y
      , Line <| Point (x - rx) y
      , Arc b b -45 False True <| Point x (y - ry)
      , Line <| Point x (y - width + ry)
      , Arc b b 45 False True <| Point (x - rx) (y - width)
      , Line <| Point 0 (y - width)
      ]


{-| -}
verticalBarCommands : Coordinate.System -> Int -> Float -> Point -> List Command
verticalBarCommands system borderRadius width { x, y }  =
  if borderRadius == 0 then
    [ Move <| Point x 0
    , Line <| Point x y
    , Line <| Point (x + width) y
    , Line <| Point (x + width) 0
    ]
  else
    if y < 0 then
      let
        b =
          toFloat borderRadius

        rx =
          scaleDataX system b

        ry =
          scaleDataY system b
      in
      [ Move <| Point x 0
      , Line <| Point x (y + ry)
      , Arc b b -45 False False <| Point (x + rx) y
      , Line <| Point (x + width - rx) y
      , Arc b b -45 False False <| Point (x + width) (y + ry)
      , Line <| Point (x + width) 0
      ]
    else
      let
        b =
          toFloat borderRadius

        rx =
          scaleDataX system b

        ry =
          scaleDataY system b
      in
      [ Move <| Point x 0
      , Line <| Point x (y - ry)
      , Arc b b -45 False True <| Point (x + rx) y
      , Line <| Point (x + width - rx) y
      , Arc b b -45 False True <| Point (x + width) (y - ry)
      , Line <| Point (x + width) 0
      ]
