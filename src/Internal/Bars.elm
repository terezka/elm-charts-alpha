module Internal.Bars
  exposing
    ( Config, default, custom
    , Bar, BarConfig, bar
    -- INTERNAL
    , borderRadius
    , barConfig, toGroups, viewGroup, variable
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
import Internal.Path as Path
import Internal.Utils as Utils
import Internal.Colors as Colors


{-| -}
type Config msg =
  Config (Properties msg)


{-| -}
type alias Properties msg =
  { label : Maybe (Float -> Label msg)
  , width : Float
  , borderRadius : Int
  }


{-| -}
type alias Label msg =
  { attributes : List (Svg.Attribute msg)
  , xOffset : Float
  , yOffset : Float
  , text : String
  }


{-| -}
default : Config msg
default =
  custom
    { label = Just defaultLabel
    , width = 100
    , borderRadius = 3
    }


defaultLabel : Float -> Label msg
defaultLabel n =
  { attributes = []
  , xOffset = 0
  , yOffset = 0
  , text = toString n
  }


{-| -}
custom : Properties msg -> Config msg
custom =
  Config


{-| -}
userWidth : Config msg -> Float
userWidth (Config config) =
  config.width


{-| -}
borderRadius : Config msg -> Int
borderRadius (Config config) =
  config.borderRadius




-- BAR


{-| -}
type Bar data =
  Bar (BarConfig data)


{-| -}
type alias BarConfig data =
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
bar : BarConfig data -> Bar data
bar =
  Bar


{-| -}
barConfig : Bar data -> BarConfig data
barConfig (Bar config) =
  config


{-| -}
variable : Bar data -> data -> Float
variable (Bar config) =
  config.variable


-- INTERNAL / GROUP


type alias BarInfo msg =
  { point : Coordinate.Point
  , index : Int
  , color : { fill : Color.Color, border : Color.Color }
  , label : Maybe (Label msg)
  , pattern : Bool
  }


toGroups : Orientation.Config -> Config msg -> List (BarConfig data) -> List data -> List (List (BarInfo msg))
toGroups orientation (Config config) barsConfigs data =
  let
    groupInfo groupIndex datum =
      List.indexedMap (barInfo groupIndex datum) barsConfigs

    barInfo groupIndex datum index bar =
      { point = point (bar.variable datum) (toFloat groupIndex + 1)
      , index = index
      , color = bar.style.emphasized datum
      , label = Maybe.map (\v -> v (bar.variable datum)) config.label
      , pattern = bar.pattern
      }

    point value position =
      case orientation of
        Orientation.Horizontal ->
          Coordinate.Point value position

        Orientation.Vertical ->
          Coordinate.Point position value
  in
  List.indexedMap groupInfo data


viewGroup : Orientation.Config -> Config msg -> Coordinate.System -> Int -> Int -> List (BarInfo msg) -> Svg.Svg msg
viewGroup orientation (Config config) system totalOfGroups totalOfBars group =
  let
    viewBarWith toProps toCommands toLabel bar =
      let
        ( width, point ) =
          toProps system config.width totalOfGroups totalOfBars bar.index bar.point

        attributes =
          List.concat
            [ Utils.addIf bar.pattern [ Svg.Attributes.mask "url(#mask-stripe)" ]
            , [ Svg.Attributes.fill (Colors.toString bar.color.fill)
              , Svg.Attributes.stroke (Colors.toString bar.color.border)
              ]
            ]
      in
      Svg.g
        [ Svg.Attributes.class "bar", Svg.Attributes.style "pointer-events: none;" ]
        [ Path.view system attributes (toCommands system config.borderRadius width point)
        , Utils.viewMaybe bar.label (toLabel system width point)
        ]

    viewBar =
      case orientation of
        Orientation.Horizontal ->
          viewBarWith toHorizontalBar Svg.horizontalBarCommands horizontalLabel

        Orientation.Vertical ->
          viewBarWith toVerticalBar Svg.verticalBarCommands verticalLabel
  in
  Svg.g [ Svg.Attributes.class "group" ] (List.map viewBar group)



-- HORIZONTAL / CALCULATIONS


toHorizontalBar : Coordinate.System -> Float -> Int -> Int -> Int -> Coordinate.Point -> ( Float, Coordinate.Point )
toHorizontalBar system userWidth totalOfGroups totalOfBars barIndex point =
  let
    offset =
      barOffset barIndex totalOfBars

    width =
      horizontalMaxWidth system userWidth totalOfGroups totalOfBars

    adjusted =
      { x = point.x + width * offset + width / 2
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


horizontalLabel : Coordinate.System -> Float -> Coordinate.Point -> Label msg -> Svg.Svg msg
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
      { x = point.x + width * offset + width / 2
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


verticalLabel : Coordinate.System -> Float -> Coordinate.Point -> Label msg -> Svg.Svg msg
verticalLabel system width point label =
  let x = point.x + width / 2 -- move to middle
      yOffset = label.yOffset - 5 -- lift above bar
  in
  Junk.labelAt system x point.y label.xOffset yOffset "middle" Color.black label.text


barOffset : Int -> Int -> Float
barOffset index totalOfBars =
  toFloat index - toFloat totalOfBars / 2
