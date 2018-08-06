module Internal.Events exposing
    ( Config, default, custom
    , Event, onClick, onMouseMove, onMouseUp, onMouseDown, onMouseLeave, on, onWithOptions, Options
    , Decoder, getSvg, getData, getNearest, getNearestBlock, getWithin, getNearestBlocks, getBlockWithin, getNearestX, getWithinX
    , Found(..), data, color, label, isExactly, isSeries, isDatum
    , map, map2, map3
    -- INTERNAL
    , toChartAttributes
    , toContainerAttributes
    )

{-| -}

import DOM
import Svg
import Svg.Events
import Html.Events
import Internal.Coordinate as Coordinate exposing (..)
import Internal.Point as Point
import Internal.Element as Element
import Internal.Orientation as Orientation
import Internal.Utils exposing (withFirst)
import Json.Decode as Json
import Color



{-| -}
type Config element data msg
  = Config (List (Event element data msg))


{-| -}
default : Config element data msg
default =
  custom []


{-| -}
custom : List (Event element data msg) -> Config element data msg
custom =
  Config



-- EVENT


{-| -}
type Event element data msg
  = Event Bool (Orientation.Config -> List (Point.Point element data) -> System -> Svg.Attribute msg)


onClick : (a -> msg) -> Decoder element data a -> Event element data msg
onClick =
  on "click"


{-| -}
onMouseMove : (a -> msg) -> Decoder element data a -> Event element data msg
onMouseMove =
  on "mousemove"


{-| -}
onMouseDown : (a -> msg) -> Decoder element data a -> Event element data msg
onMouseDown =
  on "mousedown"


{-| -}
onMouseUp : (a -> msg) -> Decoder element data a -> Event element data msg
onMouseUp =
  on "mouseup"


{-| -}
onMouseLeave : msg -> Event element data msg
onMouseLeave msg =
  Event False <| \_ _ _ ->
    Svg.Events.on "mouseleave" (Json.succeed msg)


{-| -}
on : String -> (a -> msg) -> Decoder element data a -> Event element data msg
on event toMsg decoder =
  Event False <| \orientation data system ->
    Svg.Events.on event (toJsonDecoder orientation data system (map toMsg decoder))


{-| -}
onWithOptions : String -> Options -> (a -> msg) -> Decoder element data a -> Event element data msg
onWithOptions event options toMsg decoder =
  Event options.catchOutsideChart <| \orientation data system ->
    Html.Events.onWithOptions event
      (Html.Events.Options options.stopPropagation options.preventDefault)
      (toJsonDecoder orientation data system (map toMsg decoder))


{-| -}
type alias Options =
  { stopPropagation : Bool
  , preventDefault : Bool
  , catchOutsideChart : Bool
  }


-- INTERNAL


{-| -}
toChartAttributes : Orientation.Config -> List (Point.Point element data) -> System -> Config element data msg -> List (Svg.Attribute msg)
toChartAttributes orientation data system (Config events) =
  let
    order (Event outside event) =
      if outside then Nothing else Just (event orientation data system)
  in
  List.filterMap order events


{-| -}
toContainerAttributes : Orientation.Config -> List (Point.Point element data) -> System -> Config element data msg -> List (Svg.Attribute msg)
toContainerAttributes orientation data system (Config events) =
  let
    order (Event outside event) =
      if outside then Just (event orientation data system) else Nothing
  in
  List.filterMap order events



-- SEARCHERS


{-| -}
type Decoder element data msg =
  Decoder (Orientation.Config -> List (Point.Point element data) -> System -> Point -> msg)


{-| -}
getSvg : Decoder element data Point
getSvg =
  Decoder <| \_ _ system searched ->
    searched


{-| -}
getData : Decoder element data Point
getData =
  Decoder <| \_ _ system searchedSvg ->
    Coordinate.toData system searchedSvg


{-| -}
getNearest : Decoder element data (Maybe (Found element data))
getNearest =
  Decoder <| \_ points system searchedSvg ->
    let searched = Coordinate.toData system searchedSvg in
    getNearestHelp points system searched
      |> Maybe.map Found


{-| -}
getWithin : Float -> Decoder element data (Maybe (Found element data))
getWithin radius =
  Decoder <| \_ points system searchedSvg ->
    let searched = Coordinate.toData system searchedSvg
        keepIfEligible closest =
          if withinRadius system radius searched closest.coordinates
            then Just closest
            else Nothing
    in
    getNearestHelp points system searched
      |> Maybe.andThen keepIfEligible
      |> Maybe.map Found


{-| -}
getNearestX : Decoder element data (List (Found element data))
getNearestX =
  Decoder <| \orientation points system searchedSvg ->
    let searched = Coordinate.toData system searchedSvg in
    getNearestIndependentHelp orientation points system searched
      |> List.map Found


{-| -}
getNearestBlock : Decoder Element.Block data (Maybe (Found Element.Block data))
getNearestBlock =
  Decoder <| \orientation points system searchedSvg ->
    let searched = Coordinate.toData system searchedSvg in
    getNearestIndependentHelp orientation points system searched
      |> List.map Found
      |> List.head


{-| -}
getNearestBlocks : Decoder Element.Block data (List (Found Element.Block data))
getNearestBlocks =
  Decoder <| \orientation points system searchedSvg ->
    let searched = Coordinate.toData system searchedSvg 
        isEqual = 
          Orientation.chooses orientation
            { horizontal = \point -> round point.coordinates.y == round searched.y
            , vertical = \point -> round point.coordinates.x == round searched.x
            }
    in
    points
      |> List.filter isEqual 
      |> List.map Found


{-| -}
getBlockWithin : Float -> Decoder Element.Block data (List (Found Element.Block data))
getBlockWithin radius =
  Decoder <| \orientation points system searchedSvg ->
    let searched = Coordinate.toData system searchedSvg
        keepIfEligible =
          Orientation.chooses orientation
            { horizontal = withinRadiusY system radius searched << .coordinates
            , vertical = withinRadiusX system radius searched << .coordinates
            }
    in
    getNearestIndependentHelp orientation points system searched
      |> List.filter keepIfEligible
      |> List.map Found


{-| -}
getWithinX : Float -> Decoder chart data (List (Found chart data))
getWithinX radius =
  Decoder <| \orientation points system searchedSvg ->
    let searched = Coordinate.toData system searchedSvg
        keepIfEligible = withinRadiusX system radius searched << .coordinates
    in
    getNearestIndependentHelp orientation points system searched
      |> List.filter keepIfEligible
      |> List.map Found



-- FOUND 


{-| -}
type Found element data =
  Found (Point.Point element data)


{-| -} -- TODO rename to source
data : Found element data -> data
data (Found point) =
  point.source


{-| -}
label : Found element data -> String
label (Found point) =
  point.element.label


{-| -}
color : Found element data -> Color.Color
color (Found point) =
  point.element.color


{-| -}
isExactly : Maybe (Found element data) -> Int -> data -> Bool
isExactly found index compared =
  case found of
    Just (Found point) -> point.element.seriesIndex == index && compared == point.source
    Nothing -> False


{-| -}
isSeries : Maybe (Found element data) -> Int -> data -> Bool
isSeries found index _ =
  case found of
    Just (Found point) -> point.element.seriesIndex == index
    Nothing -> False


{-| -}
isDatum : Maybe (Found element data) -> Int -> data -> Bool
isDatum found index compared =
  case found of
    Just (Found point) -> compared == point.source
    Nothing -> False



-- MAPS


{-| -}
map : (a -> msg) -> Decoder element data a -> Decoder element data msg
map f (Decoder a) =
  Decoder <| \o ps s p -> f (a o ps s p)


{-| -}
map2 : (a -> b -> msg) -> Decoder element data a -> Decoder element data b -> Decoder element data msg
map2 f (Decoder a) (Decoder b) =
  Decoder <| \o ps s p -> f (a o ps s p) (b o ps s p)


{-| -}
map3 : (a -> b -> c -> msg) -> Decoder element data a -> Decoder element data b -> Decoder element data c -> Decoder element data msg
map3 f (Decoder a) (Decoder b) (Decoder c) =
  Decoder <| \o ps s p -> f (a o ps s p) (b o ps s p) (c o ps s p)



-- HELPERS


getNearestHelp : List (Point.Point element data) -> System -> Point -> Maybe (Point.Point element data)
getNearestHelp points system searched =
  let distance_ = distance system searched
      getClosest point closest =
        if distance_ closest.coordinates < distance_ point.coordinates
          then closest
          else point
  in withFirst points (List.foldl getClosest)


getNearestIndependentHelp : Orientation.Config -> List (Point.Point element data) -> System -> Point -> List (Point.Point element data)
getNearestIndependentHelp orientation =
  Orientation.chooses orientation
    { horizontal = getNearestYHelp
    , vertical = getNearestXHelp
    }


getNearestXHelp : List (Point.Point element data) -> System -> Point -> List (Point.Point element data)
getNearestXHelp points system searched =
  let distanceX_ = distanceX system searched
      getClosest point allClosest =
        case List.head allClosest of
          Just closest ->
            if closest.coordinates.x == point.coordinates.x then point :: allClosest
            else if distanceX_ closest.coordinates > distanceX_ point.coordinates then [ point ]
            else allClosest

          Nothing ->
            [ point ]
  in List.foldl getClosest [] points


getNearestYHelp : List (Point.Point element data) -> System -> Point -> List (Point.Point element data)
getNearestYHelp points system searched =
  let distanceY_ = distanceY system searched
      getClosest point allClosest =
        case List.head allClosest of
          Just closest ->
            if closest.coordinates.y == point.coordinates.y then point :: allClosest
            else if distanceY_ closest.coordinates > distanceY_ point.coordinates then [ point ]
            else allClosest

          Nothing ->
            [ point ]
  in List.foldl getClosest [] points



-- COORDINATE HELPERS


-- TODO move to .Coordinate
distanceX : System -> Point -> Point -> Float
distanceX system searched dot =
    abs <| toSvgX system dot.x - toSvgX system searched.x


distanceY : System -> Point -> Point -> Float
distanceY system searched dot =
    abs <| toSvgY system dot.y - toSvgY system searched.y


distance : System -> Point -> Point -> Float
distance system searched dot =
    sqrt <| distanceX system searched dot ^ 2 + distanceY system searched dot ^ 2


withinRadius : System -> Float -> Point -> Point -> Bool
withinRadius system radius searched dot =
    distance system searched dot <= radius


withinRadiusX : System -> Float -> Point -> Point -> Bool
withinRadiusX system radius searched dot =
    distanceX system searched dot <= radius


withinRadiusY : System -> Float -> Point -> Point -> Bool
withinRadiusY system radius searched dot =
    distanceY system searched dot <= radius



-- DECODER


{-| -}
toJsonDecoder : Orientation.Config -> List (Point.Point element data) -> System -> Decoder element data msg -> Json.Decoder msg
toJsonDecoder orientation data system (Decoder decoder) =
  let
    handle mouseX mouseY { left, top, height, width } =
      let
        widthPercent = width / system.frame.size.width
        heightPercent = height / system.frame.size.height

        newSize =
          { width = width
          , height = height
          }

        newMargin =
          { top = system.frame.margin.top * heightPercent
          , right = system.frame.margin.right * widthPercent
          , bottom = system.frame.margin.bottom * heightPercent
          , left = system.frame.margin.left * widthPercent
          }

        newSystem =
          { system | frame = { size = newSize, margin = newMargin } }

        x = (mouseX - left)
        y = (mouseY - top)
      in
      decoder orientation data newSystem <| Point x y
  in
  Json.map3 handle
    (Json.field "pageX" Json.float) -- TODO
    (Json.field "pageY" Json.float)
    (DOM.target position)


position : Json.Decoder DOM.Rectangle
position =
  Json.oneOf
    [ DOM.boundingClientRect
    , Json.lazy (\_ -> DOM.parentElement position)
    ]
