module Internal.Coordinate exposing
  ( System, Frame, Size, Margin, Range
  , size
  , range, minimum, minimumOrZero, maximum, maximumOrZero
  , ground, reachX, reachY, lengthX, lengthY
  , smallestRange, largestRange
  , Point, toSvg, toData
  , toSvgX, toSvgY
  , toDataX, toDataY
  , scaleSvgX, scaleSvgY
  , scaleDataX, scaleDataY
  , horizontalPoint, verticalPoint
  )


{-| -}



{-| -}
type alias System =
  { frame : Frame
  , x : Range
  , y : Range
  , xData : Range
  , yData : Range
  , id : String
  }


{-| -}
type alias Frame =
  { margin : Margin
  , size : Size
  }


{-| -}
type alias Size =
  { width : Float
  , height : Float
  }


{-| -}
type alias Margin =
  { top : Float
  , right : Float
  , bottom : Float
  , left : Float
  }


{-| -}
type alias Range =
  { min : Float
  , max : Float
  }


size : Int -> Int -> Size 
size w h =
  Size (toFloat w) (toFloat h)


-- HELPERS


{-| -}
range : (a -> Float) -> List a -> Range
range toValue data =
  let
    range =
      { min = minimum toValue data
      , max = maximum toValue data
      }
  in
  if range.min == range.max then
    { range | max = range.max + 1 }
  else
    range


{-| -}
minimum : (a -> Float) -> List a -> Float
minimum toValue =
  List.map toValue
    >> List.minimum
    >> Maybe.withDefault 0


{-| -}
minimumOrZero : (a -> Float) -> List a -> Float
minimumOrZero toValue =
  minimum toValue >> Basics.min 0


{-| -}
maximum : (a -> Float) -> List a -> Float
maximum toValue =
  List.map toValue
    >> List.maximum
    >> Maybe.withDefault 1


{-| -}
maximumOrZero : (a -> Float) -> List a -> Float
maximumOrZero toValue =
  maximum toValue >> Basics.max 0


{-| -}
ground : Range -> Range
ground range =
  { range | min = Basics.min range.min 0 }


{-| -}
reachX : System -> Float
reachX system =
  let
    diff =
      system.x.max - system.x.min
  in
    if diff > 0 then diff else 1


{-| -}
reachY : System -> Float
reachY system =
  let
    diff =
      system.y.max - system.y.min
  in
    if diff > 0 then diff else 1


{-| -}
lengthX : System -> Float
lengthX system =
  max 1 (system.frame.size.width - system.frame.margin.left - system.frame.margin.right)


{-| -}
lengthY : System -> Float
lengthY system =
  max 1 (system.frame.size.height - system.frame.margin.bottom - system.frame.margin.top)


{-| -}
smallestRange : Range -> Range -> Range
smallestRange data range =
  { min = Basics.max data.min range.min
  , max = Basics.min data.max range.max
  }


{-| -}
largestRange : Range -> Range -> Range
largestRange data range =
  { min = Basics.min data.min range.min
  , max = Basics.max data.max range.max
  }



-- PUBLIC


{-| Translate a x-coordinate from data-space to SVG-space.
-}
toSvgX : System -> Float -> Float
toSvgX system value =
  scaleSvgX system (value - system.x.min) + system.frame.margin.left


{-| Translate a y-coordinate from data-space to SVG-space.
-}
toSvgY : System -> Float -> Float
toSvgY system value =
  scaleSvgY system (system.y.max - value) + system.frame.margin.top


{-| Translate a x-coordinate from SVG-space to data-space.
-}
toDataX : System -> Float -> Float
toDataX system value =
  system.x.min + scaleDataX system (value - system.frame.margin.left)


{-| Translate a y-coordinate from SVG-space to data-space.
-}
toDataY : System -> Float -> Float
toDataY system value =
  system.y.max - scaleDataY system (value - system.frame.margin.top)



-- Scaling


{-| Scale a x-value from data-space to SVG-space.
-}
scaleSvgX : System -> Float -> Float
scaleSvgX system value =
  value * (lengthX system) / (reachX system)


{-| Scale a y-value from data-space to SVG-space.
-}
scaleSvgY : System -> Float -> Float
scaleSvgY system value =
  value * (lengthY system) / (reachY system)


{-| Scale a x-value from SVG-space to data-space.
-}
scaleDataX : System -> Float -> Float
scaleDataX system value =
  value * (reachX system) / (lengthX system)


{-| Scale a y-value from SVG-space to data-space.
-}
scaleDataY : System -> Float -> Float
scaleDataY system value =
  value * (reachY system) / (lengthY system)



-- Points


{-| -}
type alias Point =
  { x : Float
  , y : Float
  }


{-| Translates a data-space point to a SVG-space point.
-}
toSvg : System -> Point -> Point
toSvg system point =
  { x = toSvgX system point.x
  , y = toSvgY system point.y
  }


{-| Translates a SVG-space point to a data-space point.
-}
toData : System -> Point -> Point
toData system point =
  { x = toDataX system point.x
  , y = toDataY system point.y
  }



-- ORIENTATION


{-| -}
horizontalPoint : Float -> Float -> Point
horizontalPoint dependent independent =
    Point independent dependent


{-| -}
verticalPoint : Float -> Float -> Point
verticalPoint dependent independent =
    Point dependent independent

