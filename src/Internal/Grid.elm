module Internal.Grid exposing (Config, default, none, dots, lines, view)


{-| -}

import Svg
import Svg.Attributes as Attributes
import Internal.Svg as Svg
import Internal.Colors as Colors
import Internal.Utils as Utils
import Internal.Coordinate as Coordinate
import Internal.Axis.Ticks as Ticks
import Color
import Color.Convert



{-| -}
type Config
  = Dots Float Color.Color
  | Lines Float Color.Color


{-| -}
default : Config
default =
  lines 1 Colors.grayLightest


{-| -}
none : Config
none =
   dots 0 Colors.transparent


{-| -}
dots : Float -> Color.Color -> Config
dots =
  Dots


{-| -}
lines : Float -> Color.Color -> Config
lines =
  Lines



-- INTERNAL


{-| -}
view : Ticks.Config msg -> Ticks.Config msg -> Config -> Coordinate.System -> Svg.Svg msg
view xTicks yTicks grid system =
  let
    verticals =
      Ticks.ticks system.xData system.x xTicks
        |> List.filterMap hasGrid

    horizontals =
      Ticks.ticks system.yData system.y yTicks
        |> List.filterMap hasGrid

    hasGrid tick =
      if tick.config.grid then Just tick.position else Nothing
  in
  Svg.g [ Attributes.class "chart__grids" ] <|
    case grid of
      Dots radius color -> viewDots  system verticals horizontals radius color
      Lines width color -> viewLines system verticals horizontals width color


viewDots : Coordinate.System -> List Float -> List Float -> Float -> Color.Color -> List (Svg.Svg msg)
viewDots system verticals horizontals radius color =
  let
    dots =
      List.concatMap dots_ verticals

    dots_ g =
      List.map (dot g) horizontals

    dot x y =
      Coordinate.toSvg system (Coordinate.Point x y)
  in
  List.map (Svg.gridDot radius color) dots


viewLines : Coordinate.System -> List Float -> List Float -> Float -> Color.Color -> List (Svg.Svg msg)
viewLines system verticals horizontals width color =
  let
    attributes =
      [ Attributes.strokeWidth (toString width), Attributes.stroke (Color.Convert.colorToCssRgba color) ]
  in
  List.map (Svg.horizontalGrid attributes >> Utils.apply system) horizontals ++
  List.map (Svg.verticalGrid attributes >> Utils.apply system) verticals
