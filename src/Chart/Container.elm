module Chart.Container exposing
  ( Config, Properties, Size, Margin
  , default, spaced, styled, responsive, custom
  )

{-|


@docs Config, default, spaced, styled, responsive

# Customization
@docs custom, Properties, Margin

## Sizing
@docs Size

-}

import Html
import Svg
import Internal.Container as Container



{-| Use in the `Chart.Config` passed to `Chart.viewCustom`.

    chartConfig : Chart.Config Data Msg
    chartConfig =
      { ...
      , conatiner = Container.default
      , ...
      }

-}
type alias Config msg =
  Container.Config msg


{-| The default container configuration.

Pass the id.

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Container/Example1.elm)._

-}
default : String -> Int -> Int -> Config msg
default =
  Container.default


{-| The default container configuration, but you decide the margins.

Pass the id, the width and height, and the top, right, bottom, and left margin respectivily.

    customContainer : Container.Config msg
    customContainer =
      Container.spaced "line-chart-1" 700 400 60 100 60 70


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Container/Example4.elm)._

-}
spaced : String -> Int -> Int -> Float -> Float -> Float -> Float -> Config msg
spaced =
  Container.spaced


{-| The default container configuration, but you can add some extra styles.

Pass the id, the width and height and styles in form of tupels of strings.

    customContainer : Container.Config msg
    customContainer =
      Container.styled "line-chart-1" [ ( "font-family", "monospace" ) ]

Ok, so we have `spaced` if we want to set the margins and `styled` if
we want to set the styles; but what if I want to set the margins AND the
styles? If so, use `custom`!

-}
styled : String -> Int -> Int -> List ( String, String ) -> Config msg
styled =
  Container.styled


{-| Makes the chart take the size of your container.

Pass the id, and the width and height

_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Container/Example2.elm)._

-}
responsive : String -> Int -> Int -> Config msg
responsive =
  Container.responsive


{-| -}
type alias Properties msg =
  { attributesHtml : List (Html.Attribute msg)
  , attributesSvg : List (Svg.Attribute msg)
  , responsive : Bool
  , size : Container.Size
  , margin : Margin
  , id : String
  }


{-| -}
type alias Size =
  { width : Int
  , height : Int
  }


{-| -}
type alias Margin =
  { top : Float
  , right : Float
  , bottom : Float
  , left : Float
  }


{-| Properties:

  - **attributesHtml** are attributes which will go on it's internal `div` container.
  - **attributesSvg** are attributes which will go on it's internal `svg` container.
  - **size** is the width and height.
  - **responsive** determines whether your chart scales to the size of the parent div.
  - **margin** adds margin around the chart.
  - **id** sets the id. It's important for this to be unique for every chart
    on your page.


    containerConfig : Container.Config msg
    containerConfig =
      Container.custom
        { attributesHtml = [ Html.Attributes.style [ ( "font-family", "monospace" ) ] ]
        , attributesSvg = []
        , size = Container.Size 600 400
        , responsive = False
        , margin = Container.Margin 30 100 60 80
        , id = "chart-id"
        }


_See the full example [here](https://github.com/terezka/line-charts/blob/master/examples/Docs/Container/Example3.elm)._

-}
custom : Properties msg -> Config msg
custom =
  Container.custom


