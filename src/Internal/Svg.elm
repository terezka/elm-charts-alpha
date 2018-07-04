module Internal.Svg exposing (..)

{-| -}

import Svg exposing (Svg, Attribute, g)
import Svg.Attributes as Attributes
import Internal.Colors as Colors
import Internal.Coordinate as Coordinate exposing (..)
import Internal.Path as Path exposing (..)
import Internal.Utils exposing (..)
import Color
import Color.Convert


{-| -}
none : Svg msg
none =
  Svg.text ""


{-| -}
c : String -> List (Svg.Attribute msg) -> List (Svg msg) -> Svg msg
c name attributes =
  Svg.g (Attributes.class ("chart__" ++ name) :: attributes)



-- CHART AREA


{-| -}
withinChartArea : Coordinate.System -> Svg.Attribute msg
withinChartArea { id } =
  Attributes.clipPath <| "url(#" ++ toChartAreaId id ++ ")"



-- SQUARE


{-| -}
square : Float -> Int -> Color.Color -> Color.Color -> Svg msg
square width radius fill border =
  -- TODO add pattern and border radius
  Svg.rect
    [ Attributes.y (toString (-width / 2))
    , Attributes.width (toString width)
    , Attributes.height (toString width)
    , Attributes.fill (Color.Convert.colorToCssRgba fill)
    , Attributes.stroke (Color.Convert.colorToCssRgba border)
    , Attributes.rx (toString radius)
    , Attributes.ry (toString radius)
    ]
    []



-- CIRCLE


{-| -}
circle_ : Float -> Color.Color -> Point -> Svg msg
circle_ radius color point =
  Svg.circle
    [ Attributes.cx (toString point.x)
    , Attributes.cy (toString point.y)
    , Attributes.r (toString radius)
    , Attributes.fill (Color.Convert.colorToCssRgba color)
    ]
    []



-- AXIS / GRID


{-| -}
horizontal : List (Attribute msg) -> Float -> Float -> Float -> Coordinate.System -> Svg msg
horizontal userAttributes y x1 x2 system =
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
vertical : List (Attribute msg) -> Float -> Float -> Float -> Coordinate.System -> Svg msg
vertical userAttributes x y1 y2 system =
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
rectangle : List (Attribute msg) -> Float -> Float -> Float -> Float -> Coordinate.System -> Svg msg
rectangle userAttributes x1 x2 y1 y2 system =
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
horizontalGrid : List (Attribute msg) -> Float -> Coordinate.System -> Svg msg
horizontalGrid userAttributes y system =
  let
    attributes =
      concat
        [ Attributes.stroke (Color.Convert.colorToCssRgba Colors.gray)
        , Attributes.style "pointer-events: none;"
        ] userAttributes []
  in
  horizontal attributes y system.x.min system.x.max system


{-| -}
verticalGrid : List (Attribute msg) -> Float -> Coordinate.System -> Svg msg
verticalGrid userAttributes x system =
  let
    attributes =
      concat
        [ Attributes.stroke (Color.Convert.colorToCssRgba Colors.gray)
        , Attributes.style "pointer-events: none;"
        ] userAttributes []
  in
  vertical attributes x system.y.min system.y.max system



-- AXIS / TICK


{-| -}
xTick : Float -> List (Attribute msg) -> Float -> Float -> Coordinate.System -> Svg msg
xTick height userAttributes y x system =
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
yTick : Float -> List (Attribute msg) -> Float -> Float -> Coordinate.System -> Svg msg
yTick width userAttributes x y system =
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
anchor : Anchor -> Svg.Attribute msg
anchor anchor =
  let anchorString =
        case anchor of
          Start -> "start"
          Middle -> "middle"
          End -> "end"
  in
  Attributes.style ("text-anchor: " ++ anchorString ++ ";")



-- TRANSFORM


{-| -}
type Transfrom =
  Transfrom Float Float


{-| -}
move : Float -> Float -> Coordinate.System -> Transfrom
move x y system =
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
  let w = Coordinate.scaleDataY system (Coordinate.scaleSvgY system width - 1)
  in
  if borderRadius == 0 then
    [ Move <| Point 0 (y - w / 2)
    , Line <| Point x (y - w / 2)
    , Line <| Point x (y + w / 2)
    , Line <| Point 0 (y + w / 2)
    ]
  else
    let b = toFloat borderRadius
        rx = scaleDataX system b
        ry = scaleDataY system b
    in
    if x < 0 then
      
      [ Move <| Point 0 (y - w / 2)
      , Line <| Point (x + rx) (y - w / 2)
      , Arc b b -45 False True <| Point x (y - w / 2 + ry)
      , Line <| Point x (y + w / 2 - ry)
      , Arc b b 45 False True <| Point (x + rx) (y + w / 2)
      , Line <| Point 0 (y + w / 2)
      ]
    else
      [ Move <| Point 0 (y - w / 2)
      , Line <| Point (x - rx) (y - w / 2)
      , Arc b b -45 False False <| Point x (y  - w / 2 + ry)
      , Line <| Point x (y + w / 2 - ry)
      , Arc b b 45 False False <| Point (x - rx) (y + w / 2)
      , Line <| Point 0 (y + w / 2)
      ]


{-| -}
verticalBarCommands : Coordinate.System -> Int -> Float -> Point -> List Command
verticalBarCommands system borderRadius width { x, y }  =
  let w = Coordinate.scaleDataX system (Coordinate.scaleSvgX system width - 1)
  in
  if borderRadius == 0 then
    [ Move <| Point (x - w / 2) 0
    , Line <| Point (x - w / 2) y
    , Line <| Point (x + w / 2) y
    , Line <| Point (x + w / 2) 0
    ]
  else
    let b = toFloat borderRadius
        rx = scaleDataX system b
        ry = scaleDataY system b
    in
    if y < 0 then
      
      [ Move <| Point (x - w / 2) 0
      , Line <| Point (x - w / 2) (y + ry)
      , Arc b b -45 False False <| Point (x - w / 2 + rx) y
      , Line <| Point (x + w / 2 - rx) y
      , Arc b b -45 False False <| Point (x + w / 2) (y + ry)
      , Line <| Point (x + w / 2) 0
      ]
    else
      [ Move <| Point (x - w / 2) 0
      , Line <| Point (x - w / 2) (y - ry)
      , Arc b b -45 False True <| Point (x - w / 2 + rx) y
      , Line <| Point (x + w / 2 - rx) y
      , Arc b b -45 False True <| Point (x + w / 2) (y - ry)
      , Line <| Point (x + w / 2) 0
      ]

