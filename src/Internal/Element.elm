module Internal.Element exposing (Element, Block, block, Dot, dot, isOutlier, LineDot, lineDot, isReal, makeFake)


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
  Dot { isOutlier : Bool }


{-| -}
dot : Bool -> Dot
dot isOutlier =
  Dot { isOutlier = isOutlier }


{-| -}
isOutlier : Element Dot -> Bool
isOutlier element =
  let (Dot { isOutlier }) = element.element in isOutlier



-- LINE DOT


{-| -}
type LineDot =
  LineDot { isReal : Bool }


{-| -}
lineDot : Bool -> LineDot
lineDot isReal =
  LineDot { isReal = isReal }


{-| -}
isReal : Element LineDot -> Bool
isReal element =
  let (LineDot { isReal }) = element.element in isReal


{-| -}
makeFake : Element LineDot -> Element LineDot
makeFake element =
  { element | element = LineDot { isReal = False } }
