module Internal.Legends exposing
  ( Config, default, none
  , grouped, groupedCustom
  -- INTERNAL
  , Arguments, view
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
  | Grouped (Float -> Float) (Container msg)


{-| -}
type alias Container msg =
  Float -> Float -> Coordinate.System -> List (Legend msg) -> Svg msg


{-| -}
type alias Legend msg =
  { sample : Svg msg
  , label : String
  }


{-| -}
default : Config msg
default =
  Grouped identity (defaultLegends .max .max 0)


{-| -}
none : Config msg
none =
  None


{-| -}
grouped : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Float -> Float -> Config msg
grouped toX toY offsetX offsetY =
  Grouped identity (\_ -> defaultLegends toX toY offsetX offsetY)


{-| -}
groupedCustom : Float -> (Coordinate.System -> List (Legend msg) -> Svg.Svg msg) -> Config msg
groupedCustom width f =
  Grouped (always width) (\_ _ -> f)



-- VIEW


{-| -}
type alias Arguments msg =
  { system : Coordinate.System
  , legends : Float -> List (Legend msg)
  , defaults : { width : Float, offsetY : Float }
  , config : Config msg
  }


{-| -}
view : Arguments msg -> Svg.Svg msg
view arguments =
  case arguments.config of
    Grouped toWidth container ->
      let width = toWidth arguments.defaults.width in
      container arguments.defaults.offsetY width arguments.system (arguments.legends width)

    None ->
      Svg.text ""



-- DEFAULTS


defaultLegends : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Float -> Container msg
defaultLegends toX toY offsetX offsetY sampleWidth system legends =
  Svg.g
    [ Attributes.class "chart__legends"
    , Svg.transform
        [ Svg.move (toX system.x) (toY system.y) system
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
