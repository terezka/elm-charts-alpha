module Chart.Junk exposing
  ( Config, default, hoverDot, hoverDots, hoverBlock, hoverBlocks, none, above, below, html
  , Transfrom, transform, move, offset, placed
  , vertical, horizontal, verticalCustom, horizontalCustom
  , rectangle, circle
  , label, labelAt
  , withinChartArea
  , hoverCustom
  )

{-|


Junk is a way to draw whatever you like in the chart. The name comes from
[Edward Tufte's concept of "chart junk"](https://en.wikipedia.org/wiki/Chartjunk).
If you want to add tooltips, sections for emphasis, or kittens on your chart,
this is where it's at.

<img alt="Legends" width="610" src="https://github.com/terezka/line-charts/blob/master/images/junk.png?raw=true"></src>

@docs Config, default, none, above, below, html, hoverBlock, hoverBlocks, hoverDot, hoverDots

# Helpers

## On chart area

A good thing to know before reading this section is what I mean by "chart area".
It is basically the rectangle which covers your entire x and y axis-range.
Below is an illustration.

_What is an axis-range? See the `Axis.Range` module._

<img alt="Legends" width="610" src="https://github.com/terezka/line-charts/blob/master/images/chartarea.png?raw=true"></src>

@docs withinChartArea

## Lines
@docs vertical, horizontal, verticalCustom, horizontalCustom

## Shapes
@docs rectangle, circle

## Label
@docs label, labelAt

## Placing
@docs placed, Transfrom, transform, move, offset

## Hover views
This is just regular html views! Nothing fancy - you can also make your own!
Notice that you can override all the styles.

@docs hoverCustom


-}

import Svg
import Svg.Attributes as Attributes
import Html
import Chart.Coordinate as Coordinate
import Chart.Events as Events
import Chart.Element as Element
import Internal.Events
import Internal.Orientation
import Internal.Point as Point
import Internal.Junk as Junk
import Internal.Svg as Svg
import Internal.Utils as Utils
import Color
import Color.Convert



-- QUICK START


{-| For the junk-free chart.
-}
default : Config element msg
default =
  Junk.none


{-| -}
none : Config element msg
none =
  Junk.none


{-| -}
below : List (Coordinate.System -> Svg.Svg msg) -> Config element msg -> Config element msg
below =
  Junk.below


{-| -}
above : List (Coordinate.System -> Svg.Svg msg) -> Config element msg -> Config element msg
above =
  Junk.above


{-| -}
html : List (Coordinate.System -> Html.Html msg) -> Config element msg -> Config element msg
html =
  Junk.html



-- CUSTOMIZE


{-| Use in the `Chart.Config` passed to `Chart.viewCustom`.

    chartConfig : Chart.Config nature Data msg
    chartConfig =
      { ...
      , junk = Junk.default
      , ...
      }

-}
type alias Config element msg =
  Junk.Config element msg


-- TODO recalc point for hover on render
{-| -}
hoverDot : Maybe (Events.Found Element.LineDot data) -> Config Element.LineDot msg
hoverDot hovered =
  case hovered of
    Nothing ->
      Junk.none

    Just (Internal.Events.Found hovered_) ->
      Junk.Config <| \args system ->
        Junk.hover
          { line = False
          , position = { x = Just hovered_.coordinates.x, y = Just hovered_.coordinates.y }
          , offset = { x = 15, y = 0 }
          , title = ( hovered_.element.color, hovered_.element.label )
          , values =
              [ ( Color.black, args.independent, hovered_.element.independent )
              , ( Color.black, args.dependent, hovered_.element.dependent )
              ]
          }


{-| -}
hoverDots : List (Events.Found Element.LineDot data) -> Config Element.LineDot msg
hoverDots hovered =
  case hovered of
    [] ->
      Junk.none

    (Internal.Events.Found first) :: _ ->
      Junk.Config <| \args system ->
        Junk.hover
          { line = True
          , position = { x = Just first.coordinates.x, y = Nothing }
          , offset = { x = 15, y = 0 }
          , title = ( Color.black, Utils.pair args.independent first.element.independent )
          , values =
              let
                value (Internal.Events.Found one) =
                  ( one.element.color, one.element.label, one.element.dependent)
              in List.map value hovered
          }


{-| -}
hoverBlock : Maybe (Events.Found Element.Block data) -> Config Element.Block msg
hoverBlock hovered =
  case hovered of
    Nothing ->
      Junk.none

    Just (Internal.Events.Found hovered_) ->
      Junk.Config <| \args system ->
        Junk.hover
          { line = False
          , position = { x = Just hovered_.coordinates.x, y = Just hovered_.coordinates.y }
          , offset =
              Internal.Orientation.chooses args.orientation
                { horizontal = { x = 0, y = -15 - Coordinate.scaleSvgY system args.offsetOne }
                , vertical = { x = 15 + Coordinate.scaleSvgX system args.offsetOne, y = 0 }
                }
          , title = ( hovered_.element.color, hovered_.element.label )
          , values =
              [ ( Color.black, args.independent, hovered_.element.independent )
              , ( Color.black, args.dependent, hovered_.element.dependent )
              ]
          }


{-| -}
hoverBlocks : List (Events.Found Element.Block data) -> Config Element.Block msg
hoverBlocks hovered =
  case hovered of
    [] ->
      Junk.none

    (Internal.Events.Found first) :: _ ->
      Junk.Config <| \args system ->
        let
            ( position, offset_ ) =
              Internal.Orientation.chooses args.orientation
                { horizontal =
                    ( { x = Nothing, y = Just (toFloat (round first.coordinates.y)) }
                    , { x = 0, y = -15 - Coordinate.scaleSvgY system args.offsetMany }
                    )
                , vertical =
                    ( { x = Just (toFloat (round first.coordinates.x)), y = Nothing }
                    , { x = 15 + Coordinate.scaleSvgX system args.offsetMany, y = 0 }
                    )
                }

            value (Internal.Events.Found one) =
              ( one.element.color, one.element.label, one.element.dependent )
        in
        Junk.hover
          { line = False
          , position = position
          , offset = offset_
          , title = ( Color.black, Utils.pair args.independent first.element.independent )
          , values = List.map value hovered
          }




-- PLACING HELPERS


{-| -}
type alias Transfrom =
  Svg.Transfrom


{-| Produces a SVG transform attributes. Useful to move elements around.

    movedStuff : Coordinate.System -> Svg.Svg msg
    movedStuff system =
      Svg.g
        [ Junk.transform
            [ Junk.move system someDataPoint.age someDataPoint.weight
            , Junk.offset 20 10
            -- Try changing the offset!
            ]
        ]
        [ Junk.label Colors.blue "stuff" ]


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Junk/Example3.elm)._

-}
transform : List Transfrom -> Svg.Attribute msg
transform =
  Svg.transform


{-| Moves in data-space.
-}
move : Float -> Float -> Coordinate.System -> Transfrom
move =
  Svg.move


{-| Moves in SVG-space.
-}
offset : Float -> Float -> Transfrom
offset =
  Svg.offset



-- COMMON


{-| Draws a vertical line, which is the full length of the y-range.

Pass the x-coordinate.

**Note:** The line is truncated off if outside the chart area.
-}
vertical : List (Svg.Attribute msg) -> Float -> Coordinate.System -> Svg.Svg msg
vertical attributes at system =
  Svg.vertical (withinChartArea system :: attributes) at system.y.min system.y.max system


{-| Draws a horizontal line which is the full length of the x-range.

Pass the y-coordinate.

**Note:** The line is truncated off if outside the chart area.
-}
horizontal : List (Svg.Attribute msg) -> Float -> Coordinate.System -> Svg.Svg msg
horizontal attributes at system =
  Svg.horizontal (withinChartArea system :: attributes) at system.x.min system.x.max system


{-| Draws a vertical line.

Pass the x-, y1- and y2-coordinates, respectively.

**Note:** The line is truncated off if outside the chart area.
-}
verticalCustom :  List (Svg.Attribute msg) -> Float -> Float -> Float -> Coordinate.System ->Svg.Svg msg
verticalCustom attributes x y1 y2 system =
  Svg.vertical (withinChartArea system :: attributes) x y1 y2 system


{-| Draws a horizontal line.

Pass the  y-, x1- and x2-coordinates, respectively.

**Note:** The line is truncated off if outside the chart area.
-}
horizontalCustom : List (Svg.Attribute msg) -> Float -> Float ->  Float -> Coordinate.System -> Svg.Svg msg
horizontalCustom attributes y x1 x2 system =
  Svg.horizontal (withinChartArea system :: attributes) y x1 x2 system


{-| Draws a rectangle. This can be used for grid bands and highlighting a
range e.g. for selection.

    xSelectionArea : Coordinate.System -> Float -> Float -> Svg msg
    xSelectionArea system startX endX =
        Junk.rectangle system
          [ Attributes.fill "rgba(255,0,0,0.1)" ]
          startX endX system.y.min system.y.max

**Note:** The rectangle is truncated off if outside the chart area.

-}
rectangle : List (Svg.Attribute msg) -> Float -> Float -> Float -> Float -> Coordinate.System -> Svg.Svg msg
rectangle attributes x1 x2 y1 y2 system =
  Svg.rectangle (withinChartArea system :: attributes) x1 x2 y1 y2 system


{-| Draws a circle. Pass the system, radius, color and x- and y-coordinates respectively.

-}
circle : Float -> Color.Color -> Float -> Float -> Coordinate.System -> Svg.Svg msg
circle radius color x y system =
  Svg.circle_ radius color <| Coordinate.toSvg system (Coordinate.Point x y)


{-| Place a list of elements on a given spot.

Arguments:
  1. The coordinate system.
  2. The x-coordinate in data-space.
  3. The y-coordinate in data-space.
  4. The x-offset in SVG-space.
  5. The y-offset in SVG-space.
  6. The list of elements

-}
placed : Float -> Float -> Float -> Float -> List (Svg.Svg msg) -> Coordinate.System -> Svg.Svg msg
placed x y xo yo children system =
  Svg.g [ transform [ move x y system, offset xo yo ] ] children



-- HELPERS


{-| Given a color, it draws the text in the second argument.
-}
label : Color.Color -> String -> Svg.Svg msg
label color =
  Svg.label (Color.Convert.colorToCssRgba color)



{-| A label, but you get to place it too.

Arguments:
  1. The coordinate system.
  2. The x-coordinate in data-space.
  3. The y-coordinate in data-space.
  4. The x-offset in SVG-space.
  5. The y-offset in SVG-space.
  6. The `text-anchor` css value.
  7. The color of the text.
  8. The text.


    customJunk : Junk.Config element msg
    customJunk =
      Junk.custom <| \system ->
        { below = []
        , above =
            [ Junk.labelAt system 2  1.5 0 -10 "middle" Colors.black "← axis range →"
            , Junk.labelAt system 2 -1.5 0  18 "middle" Colors.black "← data range →"
            -- Try changing the numbers!
            ]
        , html = []
        }

-} -- TODO add anchor type
labelAt : Float -> Float -> Float -> Float -> String -> Color.Color -> String -> Coordinate.System -> Svg.Svg msg
labelAt x y xo yo anchor color text system =
  Svg.g
    [ transform [ move x y system, offset xo yo ]
    , Attributes.style <| "text-anchor: " ++ anchor ++ ";"
    ]
    [ label color text ]


{-| An attribute which when added, truncates the rendered element if it
extends outside the chart area.
-}
withinChartArea : Coordinate.System -> Svg.Attribute msg
withinChartArea =
  Svg.withinChartArea



-- HOVER VIEWS


{-| -}
hoverCustom :
  { position : { x : Maybe Float, y : Maybe Float }
  , offset : { x : Float, y : Float }
  , styles : List ( String, String )
  , content : List (Html.Html msg)
  }
  -> Coordinate.System
  -> Html.Html msg
hoverCustom =
  Junk.hoverCustom


