module Chart.Dot exposing
  ( Shape, circle, triangle, square, diamond, plus, cross
  , Config, default, custom, customAny, hoverOne, hoverMany
  , Style, empty, disconnected, aura, full
  )

{-|

# Shapes
@docs Shape

## Selection
Hopefully, these are self-explanatory.
<img alt="Legends" width="610" style="margin-top: 10px; margin-left: -10px" src="https://github.com/terezka/line-charts/blob/master/images/shapes.png?raw=true"></src>

@docs circle, triangle, square, diamond, plus, cross

# Styles
@docs Config, default

## Hover styles
@docs hoverOne, hoverMany

## Customization
@docs custom, customAny

### Selection
@docs Style, full, empty, disconnected, aura


-}

import Internal.Dot as Dot



-- QUICK START


{-|

**Change the shape of your dots**

The shape type changes the shape of your dots.

    humanChart : Html msg
    humanChart =
      Chart.view .age .income
        [ Chart.line Colors.gold Dot.circle  "Alice" alice
        --                       ^^^^^^^^^^^
        , Chart.line Colors.blue Dot.square  "Bobby" bobby
        --                       ^^^^^^^^^^^
        , Chart.line Colors.pink Dot.diamond "Chuck" chuck
        --                       ^^^^^^^^^^^^
        ]


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Dots/Example1.elm)._

**What is a dot?**

Dots denote where your data points are on your line.
They can be different shapes (circle, square, etc.) for each line.

-}
type alias Shape =
  Dot.Shape


{-| -}
circle : Shape
circle =
  Dot.Circle


{-| -}
triangle : Shape
triangle =
  Dot.Triangle


{-| -}
square : Shape
square =
  Dot.Square


{-| -}
diamond : Shape
diamond =
  Dot.Diamond


{-| -}
plus : Shape
plus =
  Dot.Plus


{-| -}
cross : Shape
cross =
  Dot.Cross


{-|

**Change the style of your dots**

Use in the `Chart.Config` passed to `Chart.viewCustom`.

    chartConfig : Chart.Config Data Msg
    chartConfig =
      { ...
      , dots = Dot.default
      , ...
      }


**What is a dot style?**

The style of the dot includes the size of the dot and various other qualities
like whether it has a border or not. See your options under _Styles_.

-}
type alias Config data =
  Dot.Config data


{-| Draws a white outline around all your dots.
-}
default : Config data
default =
  Dot.default



-- CONFIG


{-| Change the style of _all_ your dots.

    dotsConfig : Dot.Config Data
    dotsConfig =
      Dot.custom (Dot.full 5)


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Dots/Example2.elm)._


-}
custom : Style -> Config data
custom =
  Dot.custom


{-| Change the style of _any_ of your dots. Particularly useful
for hover states, but it can also be used for creating another dimension for
your chart by varying the size of your dots based on some property.


**Extra dimension example**

    customDotsConfig : Dot.Config Data
    customDotsConfig =
      let
        styleLegend _ =
          Dot.full 7

        styleIndividual datum =
          Dot.full <| (datum.height - 1) * 12
      in
      Dot.customAny
        { legend = styleLegend
        , individual = styleIndividual
        }


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Dots/Example4.elm)._


**Hover state example**

    customDotsConfig : Maybe Data -> Dot.Config Data
    customDotsConfig maybeHovered =
      let
        styleLegend _ =
          Dot.disconnected 10 2

        styleIndividual datum =
          if Just datum == maybeHovered
            then Dot.empty 8 2
            else Dot.disconnected 10 2
      in
      Dot.customAny
        { legend = styleLegend
        , individual = styleIndividual
        }


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Dots/Example6.elm)._


-}
customAny :
  { legend : List data -> Style
  , individual : data -> Style
  }
  -> Config data
customAny =
  Dot.customAny


{-| Adds a hover effect on the given dot!

    dotsConfig : Maybe Data -> Dot.Config Data
    dotsConfig hovered =
      Dot.hoverOne hovered


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Dots/Example3.elm)._

-}
hoverOne : Maybe data -> Config data
hoverOne maybeHovered =
  let
    styleLegend _ =
      disconnected 10 2

    styleIndividual datum =
      if Just datum == maybeHovered
        then aura 7 6 0.3
        else disconnected 10 2
  in
  Dot.customAny
    { legend = styleLegend
    , individual = styleIndividual
    }


{-| Adds a hover effect on several given dots!

    dotsConfig : List Data -> Dot.Config Data
    dotsConfig hovered =
      Dot.hoverMany hovered

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Dots/Example5.elm)._

-}
hoverMany : List data -> Config data
hoverMany hovered =
  let
    styleLegend _ =
      disconnected 10 2

    styleIndividual datum =
      if List.any ((==) datum) hovered
        then aura 7 6 0.3
        else disconnected 10 2
  in
  Dot.customAny
    { legend = styleLegend
    , individual = styleIndividual
    }



-- STYLES


{-| -}
type alias Style =
  Dot.Style


{-| Makes dots plain and solid.

Pass the radius.

<img alt="Legends" width="540" src="https://github.com/terezka/line-charts/blob/master/images/dots1.png?raw=true"></src>


-}
full : Float -> Style
full =
  Dot.full


{-| Makes dots with a white core and a colored border.

Pass the radius and the width of the border.

<img alt="Legends" width="540" src="https://github.com/terezka/line-charts/blob/master/images/dots3.png?raw=true"></src>

-}
empty : Float -> Int -> Style
empty =
  Dot.empty


{-| Makes dots with a colored core and a white border.

Pass the radius and the width of the border.

<img alt="Legends" width="540" src="https://github.com/terezka/line-charts/blob/master/images/dots4.png?raw=true"></src>

-}
disconnected : Float -> Int -> Style
disconnected =
  Dot.disconnected


{-| Makes dots with a colored core and a less colored, transparent "aura".

Pass the radius, the width of the aura, and the opacity of the
aura (A number between 0 and 1).

<img alt="Legends" width="540" src="https://github.com/terezka/line-charts/blob/master/images/dots2.png?raw=true"></src>


-}
aura : Float -> Int -> Float -> Style
aura =
  Dot.aura
