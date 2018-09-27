module Chart.Events exposing
  ( Config, default, hoverDot, hoverDots, hoverBlock, hoverBlocks, click, custom
  , Event, onClick, onMouseMove, onMouseUp, onMouseDown, onMouseLeave, on, Options, onWithOptions
  , Found, data, label, color, isExactly, isSeries, isDatum
  , Decoder, getSvg, getData, getNearest, getNearestX, getWithin, getWithinX
  , map, map2, map3
  )

{-|

# WARNING! THIS IS AN ALPHA VERSION

*IT HAS MISSING, MISLEADING AND PLAIN WRONG DOCUMENTATION.*
*IT HAS BUGS AND AWKWARDNESS.*
*USE AT OWN RISK.*

@docs Config, default, hoverDot, hoverDots, hoverBlock, hoverBlocks, click

# Customization
@docs custom

## Events
@docs Event, onClick, onMouseMove, onMouseUp, onMouseDown, onMouseLeave, on, onWithOptions, Options

## Decoders
@docs Decoder, getSvg, getData, getNearest, getNearestX, getWithin, getWithinX

## Found
@docs Found, data, label, color, isExactly, isSeries, isDatum

### Maps

    type Msg =
      Hover ( Maybe Data, Coordinate.Point )

    events : Events.Config Element.Dot Data Msg
    events =
      Events.custom
        [ Events.onMouseMove Hover decoder ]

    decoder : Events.Decoder Element.Dot Data Msg
    decoder =
      Events.map2 (,) Events.getNearest Events.getSvg

@docs map, map2, map3

-}

import Internal.Events as Events
import Internal.Element as Element
import Chart.Coordinate as Coordinate
import Color



-- QUICK START


{-| Use in the `Chart.Config` passed to `Chart.viewCustom`.

    chartConfig : Chart.Config element data msg
    chartConfig =
      { ...
      , events = Events.default
      , ...
      }

-}
type alias Config element data msg =
  Events.Config element data msg


{-| Adds no events.
-}
default : Config element data msg
default =
  Events.default


{-| -}
hoverDot : (Maybe (Found element data) -> msg) -> Config element data msg
hoverDot msg =
  custom
    [ onMouseMove msg (getWithin 30)
    , on "touchstart" msg (getWithin 100)
    , on "touchmove" msg (getWithin 100)
    , onMouseLeave (msg Nothing)
    ]


{-| -}
hoverDots : (List (Found element data) -> msg) -> Config element data msg
hoverDots msg =
  custom
    [ onMouseMove msg getNearestX
    , onMouseLeave (msg [])
    ]


{-| -}
hoverBlock : (Maybe (Found Element.Block data) -> msg) -> Config Element.Block data msg
hoverBlock msg =
  custom
    [ onMouseMove msg getNearestBlock
    , on "touchstart" msg getNearestBlock
    , on "touchmove" msg getNearestBlock
    , onMouseLeave (msg Nothing)
    ]


{-| -}
hoverBlocks : (List (Found Element.Block data) -> msg) -> Config Element.Block data msg
hoverBlocks msg =
  custom
    [ onMouseMove msg getNearestBlocks
    , on "touchstart" msg getNearestBlocks
    , on "touchmove" msg getNearestBlocks
    , onMouseLeave (msg [])
    ]


{-| Sends a given message when clicking on a dot.

Pass a message taking the data of the data points clicked.

    eventsConfig : Events.Config element data msg
    eventsConfig =
      Events.click Click


_See the full example [here](https://github.com/terezka/line-elements/blob/master/examples/Docs/Events/Example3.elm)._

-}
click : (Maybe (Found element data) -> msg) -> Config element data msg
click msg =
  custom
    [ onClick msg (getWithin 30) ]


{-| Add your own combination of events. The cool thing here is that you can pick
another `Events.Decoder` or use `Events.on` for events without shortcuts.

    eventsConfig : Events.Config element data msg
    eventsConfig =
      Events.custom
        [ Events.onMouseMove Hover Events.getNearest
        , Events.onMouseLeave (Hover Nothing)
        ]


_See the full example [here](https://github.com/terezka/line-elements/blob/master/examples/Docs/Events/Example4.elm)._

This example sends the `Hover` message with the data of the _nearest_ dot when
hovering the element area and `Hover Nothing` when your leave the element area.

-}
custom : List (Event element data msg) -> Config element data msg
custom =
  Events.custom



-- SINGLES


{-| -}
type alias Event element data msg =
  Events.Event element data msg


{-| -}
onClick : (a -> msg) -> Decoder element data a -> Event element data msg
onClick =
  Events.onClick


{-| -}
onMouseMove : (a -> msg) -> Decoder element data a -> Event element data msg
onMouseMove =
  Events.onMouseMove


{-| -}
onMouseDown : (a -> msg) -> Decoder element data a -> Event element data msg
onMouseDown =
  Events.onMouseDown


{-| -}
onMouseUp : (a -> msg) -> Decoder element data a -> Event element data msg
onMouseUp =
  Events.onMouseUp


{-| -}
onMouseLeave : msg -> Event element data msg
onMouseLeave =
  Events.onMouseLeave


{-| Add any event to your element.

Arguments:

  1. The JavaScript event name.
  2. The message.
  3. The `Events.Decoder` to determine what data you want from the event.

-}
on : String -> (a -> msg) -> Decoder element data a -> Event element data msg
on =
  Events.on


{-| Same as `on`, but you can add some options too!

    1. The JavaScript event name.
    2. The `Options`.
    2. The message.
    3. The `Events.Decoder` to determine what data you want from the event.
-}
onWithOptions : String -> Options -> (a -> msg) -> Decoder element data a -> Event element data msg
onWithOptions =
  Events.onWithOptions


{-| -}
type alias Options =
  { stopPropagation : Bool
  , preventDefault : Bool
  , catchOutsideChart : Bool
  }



-- DECODERS


{-| Gets you information about where your event happened on your element.
This example gets you the data of the nearest dot to where you are hovering.

    events : Config element data msg
    events =
      Events.custom
        [ Events.onMouseMove Hover Events.getNearest ]

-}
type alias Decoder element data msg =
  Events.Decoder element data msg


{-| Get the SVG-space coordinates of the event.
-}
getSvg : Decoder element data Coordinate.Point
getSvg =
  Events.getSvg


{-| Get the data-space coordinates of the event.
-}
getData : Decoder element data Coordinate.Point
getData =
  Events.getData


{-| Get the data coordinates nearest to the event.
Returns `Nothing` if you have no data showing.
-}
getNearest : Decoder element data (Maybe (Found element data))
getNearest =
  Events.getNearest


{-| Get the data coordinates nearest of the event within the radius
you provide in the first argument. Returns `Nothing` if you have no data showing.
-}
getWithin : Float -> Decoder element data (Maybe (Found element data))
getWithin =
  Events.getWithin


{-| Get the data coordinates horizontally nearest to the event.
-}
getNearestX : Decoder element data (List (Found element data))
getNearestX =
  Events.getNearestX


{-| Finds the data coordinates horizontally nearest to the event, within the
distance you provide in the first argument.
-}
getWithinX : Float -> Decoder element data (List (Found element data))
getWithinX =
  Events.getWithinX


{-| Get the data coordinates nearest to the event.
Returns `Nothing` if you have no data showing.
-}
getNearestBlock : Decoder Element.Block data (Maybe (Found Element.Block data))
getNearestBlock =
  Events.getNearestBlock


{-| -}
getNearestBlocks : Decoder Element.Block data (List (Found Element.Block data))
getNearestBlocks =
  Events.getNearestBlocks



{-| Finds the data coordinates horizontally nearest to the event, within the
distance you provide in the first argument.
-} -- TODO naming
getBlockWithin : Float -> Decoder Element.Block data (List (Found Element.Block data))
getBlockWithin =
  Events.getBlockWithin



-- DATA


{-| -}
type alias Found element data =
  Events.Found element data


{-| -}
data : Found element data -> data
data =
  Events.data


{-| -}
label : Found element data -> String
label =
  Events.label


{-| -}
color : Found element data -> Color.Color
color =
  Events.color


{-| -}
isExactly : Maybe (Found element data) -> Int -> data -> Bool
isExactly =
  Events.isExactly


{-| -}
isSeries : Maybe (Found element data) -> Int -> data -> Bool
isSeries =
  Events.isSeries


{-| -}
isDatum : Maybe (Found element data) -> Int -> data -> Bool
isDatum =
  Events.isDatum



-- MAPS


{-| -}
map : (a -> msg) -> Decoder element data a -> Decoder element data msg
map =
  Events.map


{-| -}
map2 : (a -> b -> msg) -> Decoder element data a -> Decoder element data b -> Decoder element data msg
map2 =
  Events.map2


{-| -}
map3 : (a -> b -> c -> msg) -> Decoder element data a -> Decoder element data b -> Decoder element data c -> Decoder element data msg
map3 =
  Events.map3
