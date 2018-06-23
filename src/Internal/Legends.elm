module Internal.Legends exposing
  ( Config, default, none
  , grouped, groupedCustom
  , hover, hoverOne
  -- INTERNAL
  , view
  )

{-| -}

import Svg exposing (Svg)
import Svg.Attributes as Attributes
import Internal.Coordinate as Coordinate
import Internal.Svg as Svg



-- CONFIG


{-| -}
type Config msg
  = None
  | Grouped Float (Container msg)


{-| -}
type alias Container msg =
  Coordinate.System -> List (Legend msg) -> Svg msg


{-| -}
type alias Legend msg =
  { sample : Svg msg
  , label : String
  }


{-| -}
default : Float -> Float -> Config msg
default width offsetY =
  hover width offsetY []


{-| -}
hover : Float -> Float -> List data -> Config msg
hover width offsetY data =
  Grouped width (defaultLegends .max .max 0 offsetY width data)


{-| -}
hoverOne : Float -> Float -> Maybe data -> Config msg
hoverOne width offsetY maybeOne =
  case maybeOne of
    Just data -> hover width offsetY [ data ]
    Nothing   -> hover width offsetY []


{-| -}
none : Config msg
none =
  None


{-| -}
grouped : Float -> (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Float -> Float -> Config msg
grouped width toX toY offsetX offsetY =
  Grouped width (defaultLegends toX toY offsetX offsetY width [])


{-| -}
groupedCustom : Float -> (Coordinate.System -> List (Legend msg) -> Svg.Svg msg) -> Config msg
groupedCustom =
  Grouped



-- VIEW


{-| -}
type alias Arguments msg =
  { system : Coordinate.System
  , legends : Float -> List (Legend msg)
  , config : Config msg
  }


{-| -}
view : Arguments msg -> Svg.Svg msg
view arguments =
  case arguments.config of
    Grouped sampleWidth container ->
      container arguments.system (arguments.legends sampleWidth)

    None ->
      Svg.text ""



-- DEFAULTS


defaultLegends : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Float -> Float -> Float -> List data -> Container msg
defaultLegends toX toY offsetX offsetY sampleWidth hovered system legends =
  Svg.g
    [ Attributes.class "chart__legends"
    , Svg.transform
        [ Svg.move system (toX system.x) (toY system.y)
        , Svg.offset offsetX offsetY
        ]
    ]
    (List.indexedMap (defaultLegend sampleWidth) legends)


defaultLegend : Float -> Int -> Legend msg -> Svg msg
defaultLegend sampleWidth index { sample, label } =
   Svg.g
    [ Attributes.class "chart__legend"
    , Svg.transform [ Svg.offset 20 (toFloat index * 20) ]
    ]
    [ sample
    , Svg.g
        [ Svg.transform [ Svg.offset (sampleWidth + 10) 4 ] ]
        [ Svg.label "inherit" label ]
    ]
