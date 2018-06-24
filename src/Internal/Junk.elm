module Internal.Junk exposing (..)

{-| -}

import Color
import Svg exposing (Svg)
import Html exposing (Html)
import Html.Attributes
import Internal.Coordinate as Coordinate
import Internal.Events as Events
import Internal.Data as Data
import Color.Convert


{-| -}
type Config chart msg =
  Config (chart -> Coordinate.System -> Layers msg)


type XYChart data
  = XYChart
      { hoverMany : (data -> String) -> (data -> String) -> List data -> HoverMany
      , hoverOne : List ( String, data -> String ) -> data -> HoverOne
      }


type BarChart data
  = BarChart
      { hoverMany : (data -> String) -> (Float -> String) -> List data -> HoverMany
      , hoverOne : List ( String, data -> String ) -> Events.Found Data.BarChart data -> HoverOne
      }


type alias Series data =
  ( Color.Color, String, List data )


{-| -}
none : Config chart msg
none =
  Config (\_ _ -> Layers [] [] [])


{-| -}
custom : (Coordinate.System -> Layers msg) -> Config chart msg
custom func =
  Config (\_ -> func)


{-| -}
type alias Layers msg =
  { below : List (Svg msg)
  , above : List (Svg msg)
  , html : List (Html msg)
  }


{-| -}
getLayers : chart -> Coordinate.System -> Config chart msg -> Layers msg
getLayers defaults system (Config toLayers) =
  toLayers defaults system


{-| -}
addBelow : List (Svg msg) -> Layers msg -> Layers msg
addBelow below layers =
  { layers | below = below ++ layers.below }



-- HOVERS


type alias HoverOne =
  { x : Float
  , y : Maybe Float
  , color : Color.Color
  , title : String
  , values : List ( String, String )
  }


viewHoverOne : Coordinate.System -> HoverOne -> Html.Html msg
viewHoverOne system config =
  let
    y = Maybe.withDefault (middle .y system) config.y

    viewHeaderOne =
        viewHeader [ viewColorLabel (Color.Convert.colorToCssRgba config.color) config.title ]

    viewColorLabel color label =
      Html.p
        [ Html.Attributes.style
            [ ( "margin", "0" )
            , ( "color", color )
            ]
        ]
        [ Html.text label ]

    viewValue ( label, value ) =
      viewRow "inherit" label value
  in
  hoverAt system config.x y [] <|
    viewHeaderOne :: List.map viewValue config.values



-- HOVER MANY


type alias HoverMany =
  { withLine : Bool
  , x : Float
  , title : String
  , values : List ( Color.Color, String, String )
  }


viewHoverMany : Coordinate.System -> HoverMany -> Html.Html msg
viewHoverMany system config =
  let
    viewValue ( color, label, value ) =
      viewRow (Color.Convert.colorToCssRgba color) label value
  in
  hover system config.x [] <|
    viewHeader [ Html.text config.title ] :: List.map viewValue config.values


standardStyles : List ( String, String )
standardStyles =
  [ ( "padding", "5px" )
  , ( "min-width", "100px" )
  , ( "background", "rgba(255,255,255,0.8)" )
  , ( "border", "1px solid #d3d3d3" )
  , ( "border-radius", "5px" )
  , ( "pointer-events", "none" )
  ]


viewHeader : List (Html.Html msg) -> Html.Html msg
viewHeader =
  Html.p
    [ Html.Attributes.style
        [ ( "margin-top", "3px" )
        , ( "margin-bottom", "5px" )
        , ( "padding", "3px" )
        , ( "border-bottom", "1px solid rgb(163, 163, 163)" )
        ]
    ]


viewRow : String -> String -> String -> Html.Html msg
viewRow color label value =
  Html.p
    [ Html.Attributes.style [ ( "margin", "3px" ), ( "color", color ) ] ]
    [ Html.text (label ++ ": " ++ value) ]



-- HOVER GENERAL


{-| -}
hover : Coordinate.System  -> Float -> List ( String, String ) -> List (Html.Html msg) -> Html.Html msg
hover system x styles =
  let
    y = middle .y system

    containerStyles =
      [ if shouldFlip system x
          then ( "transform", "translate(-100%, -50%)" )
          else ( "transform", "translate(0, -50%)" )
      ]
      ++ styles
  in
  hoverAt system x y containerStyles


{-| -}
hoverAt : Coordinate.System -> Float -> Float -> List ( String, String ) -> List (Html.Html msg) -> Html.Html msg
hoverAt system x y styles view =
  let
    space = if shouldFlip system x then -15 else 15
    xPercentage = (Coordinate.toSvgX system x + space) * 100 / system.frame.size.width
    yPercentage = (Coordinate.toSvgY system y)  * 100 / system.frame.size.height

    posititonStyles =
      [ ( "left", toString xPercentage ++ "%" )
      , ( "top", toString yPercentage ++ "%" )
      , ( "margin-right", "-400px" )
      , ( "position", "absolute" )
      , if shouldFlip system x
          then ( "transform", "translateX(-100%)" )
          else ( "transform", "translateX(0)" )
      ]

    containerStyles =
      standardStyles ++ posititonStyles ++ styles
  in
  Html.div [ Html.Attributes.style containerStyles ] view



-- UTILS


middle : (Coordinate.System -> Coordinate.Range) -> Coordinate.System -> Float
middle r system =
  let range = r system in
  range.min + (range.max - range.min) / 2


shouldFlip : Coordinate.System -> Float -> Bool
shouldFlip system x =
  x - system.x.min > system.x.max - x

