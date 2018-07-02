module Internal.Events exposing
    ( Config, default, custom
    , Event, onClick, onMouseMove, onMouseUp, onMouseDown, onMouseLeave, on, onWithOptions, Options
    , Decoder, getSvg, getData, getNearest, getNearestIndependent, getWithin, getWithinIndependent
    , Found(..), data, point
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
import Internal.Data as Data
import Internal.Orientation as Orientation
import Internal.Utils exposing (withFirst)
import Json.Decode as Json



{-| -}
type Config chart data msg
  = Config (List (Event chart data msg))


{-| -}
default : Config chart data msg
default =
  custom []


{-| -}
custom : List (Event chart data msg) -> Config chart data msg
custom =
  Config



-- EVENT


{-| -}
type Event chart data msg
  = Event Bool (Orientation.Config -> List (Data.Data chart data) -> System -> Svg.Attribute msg)


onClick : (a -> msg) -> Decoder chart data a -> Event chart data msg
onClick =
  on "click"


{-| -}
onMouseMove : (a -> msg) -> Decoder chart data a -> Event chart data msg
onMouseMove =
  on "mousemove"


{-| -}
onMouseDown : (a -> msg) -> Decoder chart data a -> Event chart data msg
onMouseDown =
  on "mousedown"


{-| -}
onMouseUp : (a -> msg) -> Decoder chart data a -> Event chart data msg
onMouseUp =
  on "mouseup"


{-| -}
onMouseLeave : msg -> Event chart data msg
onMouseLeave msg =
  Event False <| \_ _ _ ->
    Svg.Events.on "mouseleave" (Json.succeed msg)


{-| -}
on : String -> (a -> msg) -> Decoder chart data a -> Event chart data msg
on event toMsg decoder =
  Event False <| \orientation data system ->
    Svg.Events.on event (toJsonDecoder orientation data system (map toMsg decoder))


{-| -}
onWithOptions : String -> Options -> (a -> msg) -> Decoder chart data a -> Event chart data msg
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
toChartAttributes : Orientation.Config -> List (Data.Data chart data) -> System -> Config chart data msg -> List (Svg.Attribute msg)
toChartAttributes orientation data system (Config events) =
  let
    order (Event outside event) =
      if outside then Nothing else Just (event orientation data system)
  in
  List.filterMap order events


{-| -}
toContainerAttributes : Orientation.Config -> List (Data.Data chart data) -> System -> Config chart data msg -> List (Svg.Attribute msg)
toContainerAttributes orientation data system (Config events) =
  let
    order (Event outside event) =
      if outside then Just (event orientation data system) else Nothing
  in
  List.filterMap order events



-- SEARCHERS


{-| -}
type Decoder chart data msg =
  Decoder (Orientation.Config -> List (Data.Data chart data) -> System -> Point -> msg)


{-| -}
getSvg : Decoder chart data Point
getSvg =
  Decoder <| \_ points system searched ->
    searched


{-| -}
getData : Decoder chart data Point
getData =
  Decoder <| \_ points system searchedSvg ->
    Coordinate.toData system searchedSvg


{-| -}
getNearest : Decoder chart data (Maybe (Found chart data))
getNearest =
  Decoder <| \_ points system searchedSvg ->
    let
      searched =
        Coordinate.toData system searchedSvg
    in
    getNearestHelp points system searched
      |> Maybe.map Found


{-| -}
getWithin : Float -> Decoder chart data (Maybe (Found chart data))
getWithin radius =
  Decoder <| \_ points system searchedSvg ->
    let
      searched =
        Coordinate.toData system searchedSvg

      keepIfEligible closest =
          if withinRadius system radius searched closest.point
            then Just closest
            else Nothing
    in
    getNearestHelp points system searched
      |> Maybe.andThen keepIfEligible
      |> Maybe.map Found


{-| -}
getNearestIndependent : Decoder chart data (List (Found chart data))
getNearestIndependent =
  Decoder <| \orientation points system searchedSvg ->
    let
      searched =
        Coordinate.toData system searchedSvg
    in
    getNearestIndependentHelp orientation points system searched
      |> List.map Found


{-| -}
getWithinIndependent : Float -> Decoder chart data (List (Found chart data))
getWithinIndependent radius =
  Decoder <| \orientation points system searchedSvg ->
    let
      searched =
        Coordinate.toData system searchedSvg

      keepIfEligible =
        Orientation.chooses orientation
          { horizontal = withinRadiusY system radius searched << .point
          , vertical = withinRadiusX system radius searched << .point
          }
    in
    getNearestIndependentHelp orientation points system searched
      |> List.filter keepIfEligible
      |> List.map Found


{-| -}
type Found chart data =
  Found (Data.Data chart data)


{-| -}
data : Found chart data -> data
data (Found data) =
  data.user


{-| -}
point : Found chart data -> Coordinate.Point
point (Found data) =
  data.point



-- MAPS


{-| -}
map : (a -> msg) -> Decoder chart data a -> Decoder chart data msg
map f (Decoder a) =
  Decoder <| \o ps s p -> f (a o ps s p)


{-| -}
map2 : (a -> b -> msg) -> Decoder chart data a -> Decoder chart data b -> Decoder chart data msg
map2 f (Decoder a) (Decoder b) =
  Decoder <| \o ps s p -> f (a o ps s p) (b o ps s p)


{-| -}
map3 : (a -> b -> c -> msg) -> Decoder chart data a -> Decoder chart data b -> Decoder chart data c -> Decoder chart data msg
map3 f (Decoder a) (Decoder b) (Decoder c) =
  Decoder <| \o ps s p -> f (a o ps s p) (b o ps s p) (c o ps s p)



-- HELPERS


getNearestHelp : List (Data.Data chart data) -> System -> Point -> Maybe (Data.Data chart data)
getNearestHelp points system searched =
  let
      distance_ =
          distance system searched

      getClosest point closest =
          if distance_ closest.point < distance_ point.point
            then closest
            else point
  in
  withFirst points (List.foldl getClosest)


getNearestIndependentHelp : Orientation.Config -> List (Data.Data chart data) -> System -> Point -> List (Data.Data chart data)
getNearestIndependentHelp orientation =
  Orientation.chooses orientation
    { horizontal = getNearestYHelp
    , vertical = getNearestXHelp
    }


getNearestXHelp : List (Data.Data chart data) -> System -> Point -> List (Data.Data chart data)
getNearestXHelp points system searched =
  let
      distanceX_ =
          distanceX system searched

      getClosest point allClosest =
        case List.head allClosest of
          Just closest ->
              if closest.point.x == point.point.x then point :: allClosest
              else if distanceX_ closest.point > distanceX_ point.point then [ point ]
              else allClosest

          Nothing ->
            [ point ]
  in
  List.foldl getClosest [] points


getNearestYHelp : List (Data.Data chart data) -> System -> Point -> List (Data.Data chart data)
getNearestYHelp points system searched =
  let
      distanceY_ =
          distanceY system searched

      getClosest point allClosest =
        case List.head allClosest of
          Just closest ->
              if closest.point.y == point.point.y then point :: allClosest
              else if distanceY_ closest.point > distanceY_ point.point then [ point ]
              else allClosest

          Nothing ->
            [ point ]
  in
  List.foldl getClosest [] points



-- COORDINATE HELPERS


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
toJsonDecoder : Orientation.Config -> List (Data.Data chart data) -> System -> Decoder chart data msg -> Json.Decoder msg
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
