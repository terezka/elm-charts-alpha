module Internal.Line exposing
  ( Series, line, plain, dashed
  , Config, default, wider, custom
  , Style, style
  -- INTERNAL
  , shape, label, color, colorBase, data
  , view, viewSample
  )

{-|


-}

import Svg
import Svg.Attributes as Attributes
import Chart.Junk as Junk
import Internal.Area as Area
import Internal.Coordinate as Coordinate
import Internal.Point as Point
import Internal.Dot as Dots
import Internal.Interpolation as Interpolation
import Internal.Path as Path
import Internal.Element as Element
import Internal.Utils as Utils
import Color
import Color.Convert



-- CONFIG


{-| -}
type Series data =
  Series (SeriesConfig data)


{-| -}
type alias SeriesConfig data =
  { color : Color.Color
  , shape : Maybe Dots.Shape
  , dashing : List Float
  , label : String
  , data : List data
  }


{-| -}
label : Series data -> String
label (Series config) =
  config.label


{-| -}
shape : Series data -> Maybe Dots.Shape
shape (Series config) =
  config.shape


{-| -}
data : Series data -> List data
data (Series config) =
  config.data


{-| -}
colorBase : Series data -> Color.Color
colorBase (Series config) =
  config.color


{-| -}
color : Config data -> Series data -> List (Point.Point Element.LineDot data) -> Color.Color
color (Config config) (Series line) point =
  let
    (Style style) =
      config (List.map .source point)
  in
  style.color line.color



-- LINES


{-| -}
line : Color.Color -> Dots.Shape -> String -> List data -> Series data
line color shape label data =
  Series <| SeriesConfig color (Just shape) [] label data


{-| -}
plain : Color.Color -> String -> List data -> Series data
plain color label data =
  Series <| SeriesConfig color Nothing [] label data


{-| -}
dashed : Color.Color -> String -> List Float -> List data -> Series data
dashed color label dashing data =
  Series <| SeriesConfig color Nothing dashing label data



-- LOOK


{-| -}
type Config data =
  Config (List data -> Style)


{-| -}
default : Config data
default =
  Config <| \_ -> style 1 identity


{-| -}
wider : Float -> Config data
wider width =
  Config <| \_ -> style width identity


{-| -}
custom : (List data -> Style) -> Config data
custom =
  Config



-- STYLE


{-| -}
type Style =
  Style
    { width : Float
    , color : Color.Color -> Color.Color
    }


{-| -}
style : Float -> (Color.Color -> Color.Color) -> Style
style width color =
  Style { width = width, color = color }



-- VIEW


type alias Arguments data =
  { system : Coordinate.System
  , dotsConfig : Dots.Config data
  , interpolation : Interpolation.Config
  , lineConfig : Config data
  , area : Area.Config
  }


{-| -}
view : Arguments data -> List (Series data) -> List (List (Point.Point Element.LineDot data)) -> Svg.Svg msg
view arguments lines points =
  let
    container =
      Svg.g [ Attributes.class "chart__lines" ]

    buildSeriesViews =
      if Area.opacityContainer arguments.area < 1
        then viewStacked arguments.area
        else viewNormal
  in
  List.map2 (viewSingle arguments) lines points
    |> Utils.unzip3
    |> buildSeriesViews
    |> container


viewNormal : ( List (Svg.Svg msg), List (Svg.Svg msg), List (Svg.Svg msg) ) -> List (Svg.Svg msg)
viewNormal ( areas, lines, dots ) =
  let
    view area line dots =
      Svg.g [ Attributes.class "chart__line" ] [ area, line, dots ]
  in
  List.map3 view areas lines dots


viewStacked : Area.Config ->  ( List (Svg.Svg msg), List (Svg.Svg msg), List (Svg.Svg msg) ) -> List (Svg.Svg msg)
viewStacked area ( areas, lines, dots ) =
  let opacity = "opacity: " ++ toString (Area.opacityContainer area)
      toList l d = [ l, d ]
      bottoms = List.concat <| List.map2 toList lines dots
  in
  [ Svg.g [ Attributes.class "chart__bottoms", Attributes.style opacity ] areas
  , Svg.g [ Attributes.class "chart__tops" ] bottoms
  ]


viewSingle : Arguments data -> Series data -> List (Point.Point Element.LineDot data) -> ( Svg.Svg msg, Svg.Svg msg, Svg.Svg msg )
viewSingle arguments line points =
  let
    -- Parting
    sections =
      Utils.part (.element >> Element.isReal) points [] []

    parts =
      List.map Tuple.first sections

    -- Style
    style =
      arguments.lineConfig |> \(Config look) -> look (List.map .source points)

    -- Dots
    viewDots =
      parts
        |> List.concat
        |> List.filter (Coordinate.isWithinRange arguments.system << .coordinates)
        |> List.map (viewDot arguments line style)
        |> Svg.g [ Attributes.class "chart__dots" ]

    -- Interpolations
    commands =
      Interpolation.toCommands arguments.interpolation sections

    viewAreas () =
      Svg.g
        [ Attributes.class "chart__interpolation__area" ] <|
        List.map (viewArea arguments line style) commands

    viewSeries_ =
      Svg.g
        [ Attributes.class "chart__interpolation__line" ] <|
        List.map2 (viewSeries arguments line style) commands parts
  in
  ( Utils.viewIf (Area.hasArea arguments.area) viewAreas
  , viewSeries_
  , viewDots
  )



-- VIEW / DOT


viewDot : Arguments data -> Series data -> Style -> Point.Point Element.LineDot data -> Svg.Svg msg
viewDot arguments (Series lineConfig) (Style style) =
  Dots.viewForLines
    { system = arguments.system
    , dotsConfig = arguments.dotsConfig
    , shape = lineConfig.shape
    , color = style.color lineConfig.color
    }



-- VIEW / LINE


viewSeries : Arguments data -> Series data -> Style -> List Path.Command -> List (Point.Point Element.LineDot data) -> Svg.Svg msg
viewSeries { system, lineConfig } line style interpolation points =
  let
    attributes =
      Junk.withinChartArea system :: toSeriesAttributes line style
  in
  Utils.viewWithFirst points <| \first _ ->
    Path.view system attributes (Path.Move first.coordinates :: interpolation)


toSeriesAttributes : Series data -> Style -> List (Svg.Attribute msg)
toSeriesAttributes (Series { color, dashing }) (Style style) =
  [ Attributes.style "pointer-events: none;"
  , Attributes.class "chart__interpolation__line__fragment"
  , Attributes.stroke (Color.Convert.colorToCssRgba (style.color color))
  , Attributes.strokeWidth (toString style.width)
  , Attributes.strokeDasharray (String.join " " (List.map toString dashing))
  , Attributes.fill "transparent"
  ]



-- VIEW / AREA


viewArea : Arguments data -> Series data -> Style -> List Path.Command -> Svg.Svg msg
viewArea { system, lineConfig, area } line style interpolation =
  let
    ground point =
      Coordinate.Point point.x (Utils.towardsZero system.y)

    attributes =
      Junk.withinChartArea system
        :: Attributes.fillOpacity (toString (Area.opacitySingle area))
        :: toAreaAttributes line style area

    commands first middle last =
      Utils.concat
        [ Path.Move (ground <| Path.toPoint first), Path.Line (Path.toPoint first) ] interpolation
        [ Path.Line (ground <| Path.toPoint last) ]
  in
  Utils.viewWithEdges interpolation <| \first middle last ->
     Path.view system attributes (commands first middle last)


toAreaAttributes : Series data -> Style -> Area.Config -> List (Svg.Attribute msg)
toAreaAttributes (Series { color }) (Style style) area =
  [ Attributes.class "chart__interpolation__area__fragment"
  , Attributes.fill (Color.Convert.colorToCssRgba (style.color color))
  ]



-- VIEW / SAMPLE


{-| -}
viewSample : Dots.Config data -> Config data -> Area.Config -> Coordinate.System -> Series data -> List (Point.Point Element.LineDot data) -> Float -> Svg.Svg msg
viewSample dotsConfig lineConfig area system line data sampleWidth =
  let
    dotPosition =
      Coordinate.Point (sampleWidth / 2) 0
        |> Coordinate.toData system

    color_ =
      color lineConfig line data

    shape_ =
      shape line
  in
  Svg.g
    [ Attributes.class "chart__sample" ]
    [ viewLineSample lineConfig line area data sampleWidth
    , Dots.viewSample dotsConfig shape_ color_ system data dotPosition
    ]


viewLineSample : Config data -> Series data -> Area.Config -> List (Point.Point Element.LineDot data) -> Float -> Svg.Svg msg
viewLineSample (Config look) line area points sampleWidth =
  let
    style =
      look (List.map .source points)

    lineAttributes =
      toSeriesAttributes line style

    sizeAttributes =
      [ Attributes.x1 "0"
      , Attributes.y1 "0"
      , Attributes.x2 (toString sampleWidth)
      , Attributes.y2 "0"
      ]

    areaAttributes =
      Attributes.fillOpacity (toString (Area.opacity area))
       :: toAreaAttributes line style area

    rectangleAttributes =
      [ Attributes.x "0"
      , Attributes.y "0"
      , Attributes.height "9"
      , Attributes.width (toString sampleWidth)
      ]

    viewRectangle () =
      Svg.rect (areaAttributes ++ rectangleAttributes) []
  in
  Svg.g []
    [ Svg.line (lineAttributes ++ sizeAttributes) []
    , Utils.viewIf (Area.hasArea area) viewRectangle
    ]
