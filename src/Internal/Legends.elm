module Internal.Legends exposing
  ( Config, default, none
  , byEnding, byBeginning
  , grouped, groupedCustom
  , hover, hoverOne
  -- INTERNAL
  , view
  )

{-| -}

import Svg exposing (Svg)
import Svg.Attributes as Attributes
import Internal.Coordinate as Coordinate
import Internal.Data as Data
import Internal.Utils as Utils
import Internal.Svg as Svg



-- CONFIG


{-| -}
type Config data msg
  = None
  | Free Placement (String -> Svg msg)
  | Grouped Float (Container msg)


{-| -}
type Placement
  = Beginning
  | Ending


{-| -}
type alias Container msg =
  Coordinate.System -> List (Legend msg) -> Svg msg


{-| -}
type alias Legend msg =
  { sample : Svg msg
  , label : String
  }


{-| -}
default : Float -> Float -> Config data msg
default width offsetY =
  hover width offsetY []


{-| -}
hover : Float -> Float -> List data -> Config data msg
hover width offsetY data =
  Grouped width (defaultLegends .max .max 0 offsetY width data)


{-| -}
hoverOne : Float -> Float -> Maybe data -> Config data msg
hoverOne width offsetY maybeOne =
  case maybeOne of
    Just data -> hover width offsetY [ data ]
    Nothing   -> hover width offsetY []


{-| -}
none : Config data msg
none =
  None


{-| -}
byEnding : (String -> Svg.Svg msg) -> Config data msg
byEnding =
  Free Ending


{-| -}
byBeginning : (String -> Svg.Svg msg) -> Config data msg
byBeginning =
  Free Beginning


{-| -}
grouped : Float -> (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Float -> Float -> Config data msg
grouped width toX toY offsetX offsetY =
  Grouped width (defaultLegends toX toY offsetX offsetY width [])


{-| -}
groupedCustom : Float -> (Coordinate.System -> List (Legend msg) -> Svg.Svg msg) -> Config data msg
groupedCustom =
  Grouped



-- VIEW


{-| -}
type alias Arguments data serie msg =
  { system : Coordinate.System
  , sample : Coordinate.System -> serie -> List (Data.Data data) -> Float -> Svg.Svg msg
  , label : serie -> String
  , series : List serie
  , data : List (List (Data.Data data))
  , x : data -> Maybe Float
  , y : data -> Maybe Float
  , legends : Config data msg
  }


{-| -}
view : Arguments data serie msg -> Svg.Svg msg
view arguments =
  case arguments.legends of
    Free placement view ->
      viewFrees arguments placement view

    Grouped sampleWidth container ->
      viewGrouped arguments sampleWidth container

    None ->
      Svg.text ""



-- VIEW / FREE


viewFrees : Arguments data serie msg -> Placement -> (String -> Svg msg) -> Svg.Svg msg
viewFrees { system, series, data, label } placement view =
  Svg.g [ Attributes.class "chart__legends" ] <|
    List.map2 (viewFree system label placement view) series data


viewFree : Coordinate.System -> (serie -> String) -> Placement -> (String -> Svg msg) -> serie -> List (Data.Data data) -> Svg.Svg msg
viewFree system label placement viewLabel series data =
  let
    ( orderedPoints, anchor, xOffset ) =
      case placement of
        Beginning ->
          ( data, Svg.End, -10 )

        Ending ->
          ( List.reverse data, Svg.Start, 10 )

    transform { x, y } =
      Svg.transform
        [ Svg.move system x y
        , Svg.offset xOffset 3
        ]

    viewLegend { point } =
      Svg.g
        [ transform point, Svg.anchorStyle anchor ]
        [ viewLabel (label series) ]
  in
  Utils.viewMaybe (List.head orderedPoints) viewLegend



-- VIEW / BUCKETED


viewGrouped : Arguments data serie msg -> Float -> Container msg -> Svg.Svg msg
viewGrouped arguments sampleWidth container =
  let
    toLegend serie data =
      { sample = arguments.sample arguments.system serie data sampleWidth
      , label = arguments.label serie
      }

    legends =
      List.map2 toLegend arguments.series arguments.data
  in
  container arguments.system legends



-- DEFAULTS


defaultLegends: (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Float -> Float -> Float -> List data -> Container msg
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
