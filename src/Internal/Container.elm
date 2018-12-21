module Internal.Container exposing
  ( Config, Properties, Size, Margin
  , default, spaced, styled, responsive, custom
  , properties, styles
  )

{-| -}

import Svg
import Html
import Html.Attributes
import Internal.Coordinate as Coordinate



{-| -}
type Config msg =
  Config (Properties msg)


{-| -}
type alias Properties msg =
  { attributesHtml : List (Html.Attribute msg)
  , attributesSvg : List (Svg.Attribute msg)
  , responsive : Bool
  , size : Size
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


{-| -}
default : String -> Int -> Int -> Config msg
default id width height =
  styled id width height []


{-| -}
spaced : String -> Int -> Int -> Float -> Float -> Float -> Float -> Config msg
spaced id width height top right bottom left =
  custom
    { attributesHtml = []
    , attributesSvg = []
    , responsive = False
    , size = Size width height
    , margin = Margin top right bottom left
    , id = id
    }


{-| -}
styled : String -> Int -> Int -> List ( String, String ) -> Config msg
styled id width height styles_ =
  custom
    { attributesHtml = List.map (\(p, v) -> Html.Attributes.style p v) styles_
    , attributesSvg = []
    , responsive = False
    , size = Size width height
    , margin = Margin 60 140 60 80
    , id = id
    }


{-| -}
responsive : String -> Int -> Int -> Config msg
responsive id width height =
  custom
    { attributesHtml = []
    , attributesSvg = []
    , size = Size width height
    , responsive = True
    , margin = Margin 60 140 60 80
    , id = id
    }


{-| -}
custom : Properties msg -> Config msg
custom =
  Config



-- INTERNAL


{-| -}
properties : (Properties msg -> a) -> Config msg -> a
properties f (Config properties_) =
  f properties_


{-| -}
styles : Config msg -> Coordinate.System -> List (Html.Attribute msg)
styles (Config properties_) system =
    if properties_.responsive then
      [ Html.Attributes.style "position" "relative" ]
    else
      [ Html.Attributes.style "position" "relative"
      , Html.Attributes.style "width" (String.fromFloat system.frame.size.width ++ "px")
      , Html.Attributes.style "height" (String.fromFloat system.frame.size.height ++ "px")
      ]

