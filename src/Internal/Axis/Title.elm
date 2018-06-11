module Internal.Axis.Title exposing
  ( Config, Properties, Anchor
  , default, atAxisMax, atDataMax, atPosition
  , custom, start, middle, end
  , config
  )

import Svg exposing (Svg)
import Internal.Coordinate as Coordinate
import Internal.Svg as Svg



{-| -}
type Config msg =
  Config (Properties msg)


{-| -}
type alias Properties msg =
  { view : Svg msg
  , anchor : Maybe Svg.Anchor
  , position : Coordinate.Range -> Coordinate.Range -> Float
  , offset : ( Float, Float )
  }


{-| -}
default : String -> Config msg
default =
  atAxisMax 0 0


{-| -}
atAxisMax : Float -> Float -> String -> Config msg
atAxisMax =
  let position data range = range.max in
  atPosition position


{-| -}
atDataMax : Float -> Float -> String -> Config msg
atDataMax =
  let position data range = Basics.min data.max range.max in
  atPosition position


{-| -}
atPosition : (Coordinate.Range -> Coordinate.Range -> Float) -> Float -> Float -> String -> Config msg
atPosition position x y =
  custom position x y Nothing << Svg.label "inherit"


{-| -}
custom : (Coordinate.Range -> Coordinate.Range -> Float) -> Float -> Float -> Maybe Anchor -> Svg msg -> Config msg
custom position x y anchor title =
  Config
    { view = title
    , anchor = anchor
    , position = position
    , offset = ( x, y )
    }



-- ANCHOR


{-| -}
type alias Anchor =
  Svg.Anchor


{-| -}
start : Anchor
start =
  Svg.Start


{-| -}
middle : Anchor
middle =
  Svg.Middle


{-| -}
end : Anchor
end =
  Svg.End



-- INTERNAL


{-| -}
config : Config msg -> Properties msg
config (Config title) =
  title
