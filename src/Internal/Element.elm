module Internal.Element exposing (Element, Block, block, Dot, dot, LineDot, lineDot, isReal, makeFake)


import Color
import Internal.Junk as Junk
import Internal.Coordinate as Coordinate


{-| -}
type alias Element element =
  { element : element
  , seriesIndex : Int
  , label : String
  , color : Color.Color
  , independent : String
  , dependent : String
  }



-- BLOCK


type Block =
  Block


{-| -}
block : Block
block =
  Block



-- SCATTER DOT


{-| -}
type Dot = -- GROUP DOT?
  Dot


{-| -}
dot : Dot
dot =
  Dot



-- LINE DOT


{-| -}
type LineDot =
  LineDot { isReal : Bool }


{-| -}
lineDot : Bool -> LineDot
lineDot isReal_ =
  LineDot { isReal = isReal_ }


{-| -}
isReal : Element LineDot -> Bool
isReal element =
  let (LineDot dot_) = element.element in dot_.isReal


{-| -}
makeFake : Element LineDot -> Element LineDot
makeFake element =
  { element | element = LineDot { isReal = False } }
