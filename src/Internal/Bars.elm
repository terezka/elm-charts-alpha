module Internal.Bars
  exposing
    ( Config, default, custom
    , Series, SeriesProps, series
    -- INTERNAL
    , borderRadius
    , seriesProps, viewGroup, variable
    , userWidth, toHorizontalBar, toVerticalBar
    )

{-| -}

import Svg
import Svg.Attributes
import Color
import BarChart.Junk as Junk
import Internal.Coordinate as Coordinate
import Internal.Orientation as Orientation
import Internal.Svg as Svg
import Internal.Data as Data
import Internal.Path as Path
import Internal.Utils as Utils
import Internal.Colors as Colors


{-| -}
type Config =
  Config (ConfigProps)


{-| -}
type alias ConfigProps =
  { label : Maybe (Float -> Label)
  , width : Float
  , borderRadius : Int
  }


{-| -}
type alias Label =
  { xOffset : Float
  , yOffset : Float
  , text : String
  }


{-| -}
default : Config
default =
  custom
    { label = Just defaultLabel
    , width = 100
    , borderRadius = 3
    }


defaultLabel : Float -> Label
defaultLabel n =
  { xOffset = 0
  , yOffset = 0
  , text = toString n
  }


{-| -}
custom : ConfigProps -> Config
custom =
  Config


{-| -}
userWidth : Config -> Float
userWidth (Config config) =
  config.width


{-| -}
borderRadius : Config -> Int
borderRadius (Config config) =
  config.borderRadius




-- BAR


{-| -}
type Series data =
  Series (SeriesProps data)


{-| -}
type alias SeriesProps data =
  { title : String
  , style : { base : Style, emphasized : data -> Style }
  , variable : data -> Float
  , pattern : Bool
  }


type alias Style =
  { fill : Color.Color
  , border : Color.Color
  }


{-| -}
series : SeriesProps data -> Series data
series =
  Series


{-| -}
seriesProps : Series data -> SeriesProps data
seriesProps (Series config) =
  config


{-| -}
variable : Series data -> data -> Float
variable (Series config) =
  config.variable



-- INTERNAL / GROUP


viewGroup : Orientation.Config -> Config -> Coordinate.System -> Int -> Int -> List (Series data, Data.Data Data.BarChart data) -> Svg.Svg msg
viewGroup orientation (Config config) system totalOfGroups totalOfBars bars =
  let
    viewBarWith toProps toCommands toLabel (Series bar, data) =
      let
        ( width, point ) =
          toProps system config.width totalOfGroups totalOfBars data.barIndex data.point

        style =
          bar.style.emphasized data.user

        attributes =
          List.concat
            [ Utils.addIf bar.pattern [ Svg.Attributes.mask "url(#mask-stripe)" ]
            , [ Svg.Attributes.fill (Colors.toString style.fill)
              , Svg.Attributes.stroke (Colors.toString style.border)
              ]
            ]
      in
      Svg.g
        [ Svg.Attributes.class "bar", Svg.Attributes.style "pointer-events: none;" ]
        [ Path.view system attributes (toCommands system config.borderRadius width point)
        , Utils.viewMaybe config.label (Utils.apply (bar.variable data.user) >> toLabel system width point)
        ]

    viewBar =
      case orientation of
        Orientation.Horizontal ->
          viewBarWith toHorizontalBar Svg.horizontalBarCommands horizontalLabel

        Orientation.Vertical ->
          viewBarWith toVerticalBar Svg.verticalBarCommands verticalLabel
  in
  Svg.g [ Svg.Attributes.class "group" ] (List.map viewBar bars)



-- HORIZONTAL / CALCULATIONS


toHorizontalBar : Coordinate.System -> Float -> Int -> Int -> Int -> Coordinate.Point -> ( Float, Coordinate.Point )
toHorizontalBar system userWidth totalOfGroups totalOfBars barIndex point =
  let
    offset =
      barOffset barIndex totalOfBars

    width =
      horizontalMaxWidth system userWidth totalOfGroups totalOfBars

    adjusted =
      { x = point.x + width * offset -- + width / 2 for data point
      , y = point.y
      }
  in
  ( width, adjusted )


horizontalMaxWidth : Coordinate.System -> Float -> Int -> Int -> Float
horizontalMaxWidth system userWidth totalOfGroups totalOfBars =
  let
    maxWidth =
      Coordinate.lengthY system / toFloat totalOfGroups - 5

    width =
      Basics.min maxWidth userWidth / toFloat totalOfBars
  in
  Coordinate.scaleDataY system width


horizontalLabel : Coordinate.System -> Float -> Coordinate.Point -> Label -> Svg.Svg msg
horizontalLabel system width point label =
  let y = point.y - width / 2 -- move to middle
      xOffset = label.xOffset + 10 -- lift above bar
      yOffset = label.yOffset + 3
  in
  Junk.labelAt system point.x y xOffset yOffset "middle" Color.black label.text



-- VERTICAL / CALCULATIONS


toVerticalBar : Coordinate.System -> Float -> Int -> Int -> Int -> Coordinate.Point -> ( Float, Coordinate.Point )
toVerticalBar system userWidth totalOfGroups totalOfBars barIndex point =
  let
    offset =
      barOffset barIndex totalOfBars

    width =
      verticalMaxWidth system userWidth totalOfGroups totalOfBars

    adjusted =
      { x = point.x + width * offset
      , y = point.y
      }
  in
  ( width, adjusted )


verticalMaxWidth : Coordinate.System -> Float -> Int -> Int -> Float
verticalMaxWidth system userWidth totalOfGroups totalOfBars =
  let
    maxWidth =
      Coordinate.lengthX system / toFloat totalOfGroups - 5

    width =
      Basics.min maxWidth userWidth / toFloat totalOfBars
  in
  Coordinate.scaleDataX system width


verticalLabel : Coordinate.System -> Float -> Coordinate.Point -> Label -> Svg.Svg msg
verticalLabel system width point label =
  let x = point.x + width / 2 -- move to middle
      yOffset = label.yOffset - 5 -- lift above bar
  in
  Junk.labelAt system x point.y label.xOffset yOffset "middle" Color.black label.text


barOffset : Int -> Int -> Float
barOffset index totalOfBars =
  toFloat index - toFloat totalOfBars / 2
