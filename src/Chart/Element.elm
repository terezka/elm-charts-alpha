module Chart.Element exposing (Dot, LineDot, Block)

{-|

These are types denoting things `Chart.Events` can find
depending on what kind of chart you're using.

@docs Dot, LineDot, Block

-}

import Internal.Element as Element


{-| -}
type alias Block =
  Element.Block


{-| -}
type alias Dot =
  Element.Dot


{-| -}
type alias LineDot =
  Element.LineDot

