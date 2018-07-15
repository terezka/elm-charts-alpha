module Chart.Group exposing
  ( Config, default
  , wider, hoverOne
  , custom
  , Style, style
  )

{-|

@docs Config, default, wider, hoverOne, custom

## Styles
@docs Style, style

-}

import Internal.Group as Group
import Color



{-| Use in the `ScatterChart.Config` passed to `ScatterChart.viewCustom`.

    chartConfig : ScatterChart.Config Data msg
    chartConfig =
      { ...
      , line = Group.default
      , ...
      }

-}
type alias Config data =
  Group.Config data


{-| Makes 1px wide lines.
-}
default : Config data
default =
  Group.default


{-| Pass the desired width of your lines.

    chartConfig : ScatterChart.Config Data msg
    chartConfig =
      { ...
      , line = Group.wider 3
      , ...
      }


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Line/Example1.elm)._

-}
wider : Float -> Config data
wider =
  Group.wider


{-| Makes the line, to which the data in the first argument belongs, wider!

    chartConfig : Maybe Data -> ScatterChart.Config Data Msg
    chartConfig hovered =
      { ...
      , line = Group.hoverOne hovered
      , ...
      }


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Line/Example2.elm)._

-}
hoverOne : Maybe data -> Config data
hoverOne hovered =
  custom <| \data ->
    if List.any (Just >> (==) hovered) data then
      style 3 identity
    else
      style 1 identity


{-| Edit as style of a line based on its data.

    lineConfig : Maybe Data -> Group.Config Data
    lineConfig maybeHovered =
      Group.custom (toLineStyle maybeHovered)


    toLineStyle : Maybe Data -> List Data -> Group.Style
    toLineStyle maybeHovered lineData =
      case maybeHovered of
        Nothing -> -- No line is hovered
          Group.style 1 identity

        Just hovered -> -- Some line is hovered
          if List.any ((==) hovered) lineData then
            -- It is this one, so make it pop!
            Group.style 2 (Manipulate.darken 0.1)
          else
            -- It is not this one, so hide it a bit
            Group.style 1 (Manipulate.lighten 0.35)


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Line/Example3.elm)._

-}
custom : (List data -> Style) -> Config data
custom =
  Group.custom



-- STYLE


{-| -}
type alias Style =
  Group.Style


{-| Pass the width of the line and a function transforming the line's color.

    vanilla : Group.Style
    vanilla =
      Group.style 1 identity

    emphasize : Group.Style
    emphasize =
      Group.style 2 (Manipulate.darken 0.15)

    hide : Group.Style
    hide =
      Group.style 1 (Manipulate.lighten 0.15)

    blacken : Group.Style
    blacken =
      Group.style 2 (\_ -> Colors.black)


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Line/Example4.elm)._

-}
style : Float -> (Color.Color -> Color.Color) -> Style
style =
  Group.style
