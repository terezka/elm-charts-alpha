module Internal.Bars
  exposing
    ( Config, default, custom
    , Series, SeriesProps, series
    , Style, solid, bordered, alternate
    -- INTERNAL
    , fill, border
    , isBar, isGroup
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
import BarChart.Junk as Junk
import BarChart.Events as Events
import Internal.Coordinate as Coordinate
import Internal.Orientation as Orientation
import Internal.Svg as Svg
import Internal.Data as Data
import Internal.Path as Path
import Internal.Utils as Utils
import Internal.Colors as Colors
import Internal.Events


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



{-| -}
isBar : Maybe (Events.Found data) -> Int -> data -> Bool
isBar found index datum =
  case found of
    Just (Internal.Events.Found data) -> data.seriesIndex == index && data.user == datum
    Nothing -> False


{-| -}
isGroup : Maybe (Events.Found data) -> Int -> data -> Bool
isGroup found index datum =
  case found of
    Just (Internal.Events.Found data) -> data.user == datum
    Nothing -> False



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
viewSeries : Coordinate.System -> Orientation.Config -> Config -> Width -> Series data -> Data.Data Data.BarChart data -> Svg.Svg msg
viewSeries system orientation (Config config) width (Series series) datum =
  let
    viewBarWith toCommands toPoint toLabel =
      let
        (Style style) =
          series.style

        attributes =
          List.concat
            [ Utils.addIf series.pattern [ Svg.Attributes.mask "url(#mask-stripe)" ]
            , Colors.attributes (style.alternate datum.seriesIndex datum.user)
            ]
      in
      Svg.g
        [ Svg.Attributes.class "chart__bar", Svg.Attributes.style "pointer-events: none;" ]
        [ Path.view system attributes (toCommands system config.borderRadius width datum.point)
        , Utils.viewMaybe config.label (Utils.apply datum.point.y >> toLabel system width datum.point)
        ]
  in
  Orientation.chooses orientation
    { horizontal = viewBarWith Svg.horizontalBarCommands Coordinate.horizontalPoint horizontalLabel
    , vertical = viewBarWith Svg.verticalBarCommands Coordinate.verticalPoint verticalLabel
    }


horizontalLabel : Coordinate.System -> Float -> Coordinate.Point -> Label -> Svg.Svg msg
horizontalLabel system width point label =
  let y = point.y - width / 2 -- move to middle
      xOffset = label.xOffset + 10 -- lift above bar
      yOffset = label.yOffset + 3
  in
  Junk.labelAt system point.x y xOffset yOffset "middle" Color.black label.text


verticalLabel : Coordinate.System -> Float -> Coordinate.Point -> Label -> Svg.Svg msg
verticalLabel system width point label =
  let x = point.x + width / 2 -- move to middle
      yOffset = label.yOffset - 5 -- lift above bar
  in
  Junk.labelAt system x point.y label.xOffset yOffset "middle" Color.black label.text

