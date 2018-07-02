module Internal.Junk exposing (..)

{-| -}

import Color
import Svg exposing (Svg)
import Html exposing (Html)
import Html.Attributes
import Internal.Coordinate as Coordinate
import Internal.Svg as Svg
import Color.Convert


{-| -}
type Config chart msg =
  Config (chart -> Layers msg)


{-| -}
none : Config chart msg
none =
  Config (\_ -> Layers [] [] [])


{-| -}
below : List (Coordinate.System -> Svg msg) -> Config chart msg -> Config chart msg
below stuff (Config func) =
  let add stuff_ layers = { layers | below = layers.below ++ stuff_ } in
  Config (func >> add stuff)


{-| -}
above : List (Coordinate.System -> Svg msg) -> Config chart msg -> Config chart msg
above stuff (Config func) =
  let add stuff_ layers = { layers | above = layers.above ++ stuff_ } in
  Config (func >> add stuff)


{-| -}
html : List (Coordinate.System -> Html msg) -> Config chart msg -> Config chart msg
html stuff (Config func) =
  let add stuff_ layers = { layers | html = layers.html ++ stuff_ } in
  Config (func >> add stuff)



-- INTERNAL


{-| -}
type alias Layers msg =
  { below : List (Coordinate.System -> Svg msg)
  , above : List (Coordinate.System -> Svg msg)
  , html : List (Coordinate.System -> Html msg)
  }


{-| -}
getLayers : chart -> Config chart msg -> Layers msg
getLayers defaults (Config toLayers) =
  toLayers defaults



-- HOVERS


type alias HoverOne =
  { position : { x : Maybe Float, y : Maybe Float }
  , offset : { x : Float, y : Float }
  , color : Color.Color
  , title : String
  , values : List ( String, String )
  }


hoverOne : HoverOne -> Layers msg
hoverOne config =
  let
    viewHeaderOne =
      viewHeader [ viewRow config.color config.title ]

    viewValue ( label, value ) =
      viewRow Color.black (label ++ ": " ++ value)
  in
  { below = []
  , above = []
  , html =
      [ hoverCustom
          { position = config.position
          , offset = config.offset
          , styles = []
          , content = viewHeaderOne :: List.map viewValue config.values
          }
      ]
  }



-- HOVER MANY


type alias HoverMany msg =
  { line : Coordinate.System -> Svg.Svg msg 
  , position : { x : Maybe Float, y : Maybe Float }
  , offset : { x : Float, y : Float }
  , title : String
  , values : List ( Color.Color, String, String )
  }


hoverMany : HoverMany msg -> Layers msg
hoverMany config =
  let
    viewValue ( color, label, value ) =
      viewRow color (label ++ ": " ++ value)
  in
  { below = [ config.line ]
  , above = []
  , html =
      [ hoverCustom
          { position = config.position
          , offset = config.offset
          , styles = []
          , content = viewHeader [ Html.text config.title ] :: List.map viewValue config.values
          }
      ]
  }



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


viewRow : Color.Color -> String -> Html.Html msg
viewRow color label =
  Html.p
    [ Html.Attributes.style [ ( "margin", "3px" ), ( "color", Color.Convert.colorToCssRgba color ) ] ]
    [ Html.text label ]



-- HOVER GENERAL


hoverCustom :
  { position : { x : Maybe Float, y : Maybe Float }
  , offset : { x : Float, y : Float }
  , styles : List ( String, String )
  , content : List (Html msg)
  }
  -> Coordinate.System
  -> Html.Html msg
hoverCustom config system =
  let
    y = Maybe.withDefault (middle .y system) config.position.y
    x = Maybe.withDefault (middle .x system) config.position.x

    directionX = if shouldFlip .x system x then -1 else 1
    directionY = if shouldFlip .y system y then -1 else 1
    spaceX = directionX * config.offset.x
    spaceY = directionY * config.offset.y

    xPercentage = (Coordinate.toSvgX system x + spaceX) * 100 / system.frame.size.width
    yPercentage = (Coordinate.toSvgY system y + spaceY)  * 100 / system.frame.size.height

    transform =
      case ( config.position.x, config.position.y ) of
        ( Just _, Just _ ) ->
          case ( shouldFlip .x system x, shouldFlip .y system y ) of
            ( True, True ) ->
              ( "transform", "translate(-100%, 0)" )

            ( True, False ) ->
              ( "transform", "translate(-100%, -100%)" )

            ( False, True ) ->
              ( "transform", "translate(0, 0)" )

            ( False, False ) ->
              ( "transform", "translate(0, -100%)" )

        ( Just _, Nothing ) ->
          if shouldFlip .x system x
              then ( "transform", "translate(-100%, -50%)" )
              else ( "transform", "translate(0, -50%)" )

        ( Nothing, Just _ ) ->
          if shouldFlip .y system y
              then ( "transform", "translate(-50%, 0)" )
              else ( "transform", "translate(-50%, -100%)" )

        ( Nothing, Nothing ) ->
          ( "transform", "translate(0, 0)" )

    posititonStyles =
      [ ( "left", toString xPercentage ++ "%" )
      , ( "top", toString yPercentage ++ "%" )
      , ( "margin-right", "-400px" )
      , ( "position", "absolute" )
      , transform
      ]

    containerStyles =
      standardStyles ++ posititonStyles ++ config.styles
  in
  Html.div [ Html.Attributes.style containerStyles ] config.content



-- UTILS


middle : (Coordinate.System -> Coordinate.Range) -> Coordinate.System -> Float
middle r system =
  let range = r system in
  range.min + (range.max - range.min) / 2


shouldFlip : (Coordinate.System -> Coordinate.Range) ->Coordinate.System ->  Float -> Bool
shouldFlip r system n =
  let range = r system in
  n - range.min > range.max - n

