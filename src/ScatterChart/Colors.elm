module ScatterChart.Colors exposing
  ( pink, blue, gold, red, green, cyan, teal, purple, rust, strongBlue
  , pinkLight, blueLight, goldLight, redLight, greenLight, cyanLight, tealLight, purpleLight
  , black, gray, grayLight, grayLightest, transparent
  )

{-|

<img alt="Colors!" width="610" src="https://github.com/terezka/line-charts/blob/master/images/colors.png?raw=true"></src>

@docs pink, blue, gold, red, green, cyan, teal, purple, rust, strongBlue

## Light
@docs pinkLight, blueLight, goldLight, redLight, greenLight, cyanLight, tealLight, purpleLight

## Gray scale
@docs black, gray, grayLight, grayLightest

## Other
@docs transparent

-}

import Color
import Internal.Colors as Colors



{-| -}
pink : Color.Color
pink =
 Colors.pink


{-| -}
pinkLight : Color.Color
pinkLight =
 Colors.pinkLight


{-| -}
gold : Color.Color
gold =
 Colors.gold


{-| -}
goldLight : Color.Color
goldLight =
 Colors.goldLight


{-| -}
blue : Color.Color
blue =
 Colors.blue


{-| -}
blueLight : Color.Color
blueLight =
 Colors.blueLight


{-| -}
green : Color.Color
green =
 Colors.green


{-| -}
greenLight : Color.Color
greenLight =
 Colors.greenLight


{-| -}
red : Color.Color
red =
 Colors.red


{-| -}
redLight : Color.Color
redLight =
 Colors.redLight


{-| -}
rust : Color.Color
rust =
 Colors.rust


{-| -}
purple : Color.Color
purple =
 Colors.purple


{-| -}
purpleLight : Color.Color
purpleLight =
 Colors.purpleLight


{-| -}
cyan : Color.Color
cyan =
 Colors.cyan


{-| -}
cyanLight : Color.Color
cyanLight =
 Colors.cyanLight


{-| -}
teal : Color.Color
teal =
 Colors.teal


{-| -}
tealLight : Color.Color
tealLight =
 Colors.tealLight


{-| -}
strongBlue : Color.Color
strongBlue =
 Colors.strongBlue



-- GRAY SCALE


{-| -}
black : Color.Color
black =
  Colors.black


{-| -}
gray : Color.Color
gray =
  Colors.gray


{-| -}
grayLight : Color.Color
grayLight =
  Colors.grayLight


{-| -}
grayLightest : Color.Color
grayLightest =
  Colors.grayLightest


{-| -}
transparent : Color.Color
transparent =
 Colors.transparent
