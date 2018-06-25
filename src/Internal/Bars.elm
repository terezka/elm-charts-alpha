module Internal.Bars
  exposing
    ( Config, default, custom
    , Series, SeriesProps, series
    -- INTERNAL
    , borderRadius
    , seriesProps, variable
    , userWidth, toHorizontalBar, toVerticalBar
    --
    , width, viewSeries
    )

{-| -}

import Svg
import Svg.Attributes
import Color
import BarChart.Junk as Junk
import Internal.Coordinate as Coordinate
import Internal.Orientation as Orientation
import Internal.Svg as Svg
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



-- OFFSET


{-| -}
type alias Width =
  Float


{-| -}
width : (Coordinate.System -> Float) -> (Coordinate.System -> Float -> Float) -> Coordinate.System -> Config -> Float -> Float -> Width
width length scale system (Config config) countOfSeries countOfData =
  let widthUser = config.width
      widthMaxOrg = length system / countOfData - 5
      widthInSvg = Basics.min widthMaxOrg widthUser / countOfSeries
      width = scale system widthInSvg
  in
  width


{-| -}
viewSeries : Coordinate.System -> Orientation.Config -> Config -> Width -> Float -> List data -> Int -> Series data -> Svg.Svg msg
viewSeries system orientation (Config config) width countOfSeries data seriesIndex (Series series) =
  let
    countOfData = toFloat (List.length data)

    viewBarWith toCommands toPoint toLabel dataIndex datum =
      let
        style = series.style.emphasized datum
        offset = toFloat seriesIndex - countOfSeries / 2
        independent = toFloat dataIndex + 1 + offset * width
        dependent = series.variable datum
        point = toPoint independent dependent

        attributes =
          List.concat
            [ Utils.addIf series.pattern [ Svg.Attributes.mask "url(#mask-stripe)" ]
            , [ Svg.Attributes.fill (Colors.toString style.fill)
              , Svg.Attributes.stroke (Colors.toString style.border)
              ]
            ]
      in
      Svg.g
        [ Svg.Attributes.class "bar", Svg.Attributes.style "pointer-events: none;" ]
        [ Path.view system attributes (toCommands system config.borderRadius width point)
        , Utils.viewMaybe config.label (Utils.apply dependent >> toLabel system width point)
        ]

    viewBar =
      Orientation.chooses orientation
        { horizontal = viewBarWith Svg.horizontalBarCommands Coordinate.horizontalPoint horizontalLabel
        , vertical = viewBarWith Svg.verticalBarCommands Coordinate.verticalPoint verticalLabel
        }
  in
  Svg.g [ Svg.Attributes.class "series" ] (List.indexedMap viewBar data)



-- HORIZONTAL / CALCULATIONS


toHorizontalBar : Coordinate.System -> Float -> Int -> Int -> Int -> Coordinate.Point -> ( Float, Coordinate.Point )
toHorizontalBar system userWidth totalOfGroups totalOfBars barIndex point =
  let
    offset =
      toFloat barIndex - toFloat totalOfBars / 2

    width =
      horizontalMaxWidth system userWidth totalOfGroups totalOfBars

    adjusted =
      { y = point.y + width * offset -- + width / 2 for data point
      , x = point.x
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
      toFloat barIndex - toFloat totalOfBars / 2

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
