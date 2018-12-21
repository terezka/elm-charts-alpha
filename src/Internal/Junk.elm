module Internal.Junk exposing (..)

{-| -}

import Color
import Svg exposing (Svg)
import Html exposing (Html)
import Html.Attributes
import Internal.Coordinate as Coordinate
import Internal.Orientation as Orientation
import Internal.Svg as Svg
import Color.Convert


{-| -}
type Config element msg =
  Config (Arguments -> Coordinate.System -> Layers msg)


type alias Arguments =
  { orientation : Orientation.Config
  , independent : String
  , dependent : String
  , offsetOne : Float
  , offsetMany : Float
  }


{-| -}
none : Config element msg
none =
  Config (\_ _ -> Layers [] [] [])


{-| -}
below : List (Coordinate.System -> Svg msg) -> Config element msg -> Config element msg
below stuff (Config func) =
  let add stuff_ layers = { layers | below = layers.below ++ stuff_ } in
  Config (\o s -> add stuff (func o s))


{-| -}
above : List (Coordinate.System -> Svg msg) -> Config element msg -> Config element msg
above stuff (Config func) =
  let add stuff_ layers = { layers | above = layers.above ++ stuff_ } in
  Config (\o s -> add stuff (func o s))


{-| -}
html : List (Coordinate.System -> Html msg) -> Config element msg -> Config element msg
html stuff (Config func) =
  let add stuff_ layers = { layers | html = layers.html ++ stuff_ } in
  Config (\o s -> add stuff (func o s))



-- INTERNAL


{-| -}
type alias Layers msg =
  { below : List (Coordinate.System -> Svg msg)
  , above : List (Coordinate.System -> Svg msg)
  , html : List (Coordinate.System -> Html msg)
  }


{-| -}
getLayers : Arguments -> Coordinate.System -> Config element msg -> Layers msg
getLayers args system (Config toLayers) =
  toLayers args system



-- HOVER


type alias Frame =
  { line : Bool
  , position : { x : Maybe Float, y : Maybe Float }
  , offset : { x : Float, y : Float }
  , title : ( Color.Color, String )
  , values : List ( Color.Color, String, String )
  }


hover : Frame ->Layers msg
hover config =
  { below = [] -- TODO add line
  , above = []
  , html =
      [ hoverCustom
          { position = config.position
          , offset = config.offset
          , styles = []
          , content = viewHeader config.title :: List.map viewValue config.values
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


viewHeader : ( Color.Color, String ) -> Html.Html msg
viewHeader (color, title) =
  Html.p
    [ Html.Attributes.style "margin-top" "3px"
    , Html.Attributes.style "margin-bottom" "5px"
    , Html.Attributes.style "padding" "3px"
    , Html.Attributes.style "border-bottom" "1px solid rgb(163, 163, 163)"
    ]
    [ Html.p
        [ Html.Attributes.style "margin" "3px"
        , Html.Attributes.style "color" (Color.toCssString color)
        ]
        [ Html.text title ]
    ]


viewValue : ( Color.Color,  String, String ) -> Html.Html msg
viewValue (color, label, value) =
  Html.p
    [ Html.Attributes.style "margin" "3px"
    , Html.Attributes.style "color" (Color.toCssString color)
    ]
    [ Html.text (label ++ ": " ++ value) ]



-- HOVER CUSTOM


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
      [ ( "left", String.fromFloat xPercentage ++ "%" )
      , ( "top", String.fromFloat yPercentage ++ "%" )
      , ( "margin-right", "-400px" )
      , ( "position", "absolute" )
      , transform
      ]

    containerStyles =
      standardStyles ++ posititonStyles ++ config.styles
  in
  Html.div (List.map (\(p,v) -> Html.Attributes.style p v) containerStyles) config.content



-- UTILS


middle : (Coordinate.System -> Coordinate.Range) -> Coordinate.System -> Float
middle r system =
  let range = r system in
  range.min + (range.max - range.min) / 2


shouldFlip : (Coordinate.System -> Coordinate.Range) ->Coordinate.System ->  Float -> Bool
shouldFlip r system n =
  let range = r system in
  n - range.min > range.max - n

