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
styled id width height styles =
  custom
    { attributesHtml = [ Html.Attributes.style styles ]
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
properties f (Config properties) =
  f properties


{-| -}
styles : Config msg -> Coordinate.System -> Html.Attribute msg
styles (Config properties) system =
  Html.Attributes.style <|
    if properties.responsive then
      [ ( "position", "relative" ) ]
    else
      [ ( "position", "relative" )
      , ( "width", toString system.frame.size.width ++ "px" )
      , ( "height", toString system.frame.size.height ++ "px" )
      ]

