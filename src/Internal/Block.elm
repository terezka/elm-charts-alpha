module Internal.Block
  exposing
    ( Config, default, custom
    , Series, SeriesProps, series
    , Style, solid, bordered, alternate
    -- INTERNAL
    , fill, border
    , borderRadius
    , seriesProps, variable, color, label
    , userWidth
    --
    , width, viewSeries
    )

{-| -}

import Svg
import Svg.Attributes
import Color
import Chart.Junk as Junk
import Chart.Events as Events
import Internal.Coordinate as Coordinate
import Internal.Orientation as Orientation
import Internal.Svg as Svg
import Internal.Element as Element
import Internal.Point as Point
import Internal.Path as Path
import Internal.Utils as Utils
import Internal.Colors as Colors
import Internal.Events


{-| -}
type Config =
  Config (ConfigProps)


{-| -}
type alias ConfigProps =
  { borderRadius : Int
  , width : Float
  }


{-| -}
default : Config
default =
  custom 3 100


{-| -}
custom : Int -> Float -> Config
custom border width =
  Config (ConfigProps border width)


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
  , style : Style data
  , variable : data -> Float
  , pattern : Bool
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
color : Series data -> Color.Color
color (Series config) =
  let (Style style) = config.style in
  style.base.border


{-| -}
label : Series data -> String
label (Series config) =
  config.title


{-| -}
variable : Series data -> data -> Float
variable (Series config) =
  config.variable



-- STYLE


{-| -}
type Style data =
  Style (StyleProps data)


type alias StyleProps data =
  { base : Colors.Style
  , alternate : Int -> data -> Colors.Style
  }


{-| -}
solid : Color.Color -> Style data
solid color =
  Style
    { base = Colors.Style color color
    , alternate = \_ _ -> Colors.Style color color
    }


{-| -}
bordered : Color.Color -> Color.Color -> Style data
bordered fill border =
  Style
    { base = Colors.Style fill border
    , alternate = \_ _ -> Colors.Style fill border
    }


{-| -}
alternate : (Int -> data -> Bool) -> Style data -> Style data -> Style data
alternate condition (Style first) (Style second) =
  Style
    { base = first.base
    , alternate = \index data ->
        if condition index data
          then second.alternate index data
          else first.alternate index data
    }


{-| -}
fill : Style data -> Color.Color
fill (Style style) =
  style.base.fill


{-| -}
border : Style data -> Color.Color
border (Style style) =
  style.base.border



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



-- VIEW


{-| -}
viewSeries : Coordinate.System -> Orientation.Config -> Config -> Width -> Series data -> Point.Point Element.Block data -> Svg.Svg msg
viewSeries system orientation (Config config) width (Series series) point =
  let
    viewBarWith toCommands toPoint =
      let
        (Style style) =
          series.style

        attributes =
          List.concat
            [ Utils.addIf series.pattern [ Svg.Attributes.mask "url(#mask-stripe)" ]
            , Colors.attributes (style.alternate point.element.seriesIndex point.source)
            ]
      in
      Svg.g
        [ Svg.Attributes.class "chart__bar", Svg.Attributes.style "pointer-events: none;" ]
        [ Path.view system attributes (toCommands system config.borderRadius width point.coordinates)
        ]
  in
  Orientation.chooses orientation
    { horizontal = viewBarWith Svg.horizontalBarCommands Coordinate.horizontalPoint
    , vertical = viewBarWith Svg.verticalBarCommands Coordinate.verticalPoint
    }

