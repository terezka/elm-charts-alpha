module Internal.Group exposing
  ( Group, group
  , Config, default, wider, custom
  , Style, style
  -- INTERNAL
  , shape, label, color, colorBase, data
  , view, viewSample
  )

{-|


-}

import Svg
import Svg.Attributes as Attributes
import Internal.Coordinate as Coordinate
import Internal.Data as Data
import Internal.Dots as Dots
import Internal.Outliers as Outliers
import Color



-- CONFIG


{-| -}
type Group data =
  Group (GroupConfig data)


{-| -}
type alias GroupConfig data =
  { color : Color.Color
  , shape : Dots.Shape
  , dashing : List Float
  , label : String
  , data : List data
  }


{-| -}
label : Group data -> String
label (Group config) =
  config.label


{-| -}
shape : Group data -> Dots.Shape
shape (Group config) =
  config.shape


{-| -}
data : Group data -> List data
data (Group config) =
  config.data


{-| -}
colorBase : Group data -> Color.Color
colorBase (Group config) =
  config.color


{-| -}
color : Config data -> Group data -> List (Data.ScatterChart data) -> Color.Color
color (Config config) (Group line) data =
  let
    (Style style) =
      config (List.map .user data)
  in
  style.color line.color



-- LINES


{-| -}
group : Color.Color -> Dots.Shape -> String -> List data -> Group data
group color shape label data =
  Group <| GroupConfig color shape [] label data



-- LOOK


{-| -}
type Config data =
  Config (List data -> Style)


{-| -}
default : Config data
default =
  Config <| \_ -> style 1 identity


{-| -}
wider : Float -> Config data
wider width =
  Config <| \_ -> style width identity


{-| -}
custom : (List data -> Style) -> Config data
custom =
  Config



-- STYLE


{-| -}
type Style =
  Style
    { width : Float
    , color : Color.Color -> Color.Color
    }


{-| -}
style : Float -> (Color.Color -> Color.Color) -> Style
style width color =
  Style { width = width, color = color }



-- VIEW


type alias Arguments data =
  { system : Coordinate.System
  , dotsConfig : Dots.Config data
  , lineConfig : Config data
  , outliersConfig : Outliers.Config data
  }


{-| -}
view : Arguments data -> List (Group data) -> List (List (Data.ScatterChart data)) -> Svg.Svg msg
view arguments lines datas =
  let
    container =
      Svg.g [ Attributes.class "chart__groups" ]
  in
  List.map2 (viewSingle arguments) lines datas
    |> container


viewSingle : Arguments data -> Group data -> List (Data.ScatterChart data) -> Svg.Svg msg
viewSingle arguments line data =
  let
    -- Style
    style =
      arguments.lineConfig |> \(Config look) -> look (List.map .user data)

    -- Dots
    viewDots =
      data
        |> List.filter (Data.isWithinRange arguments.system << .point)
        |> List.map (viewDot arguments line style)
        |> Svg.g [ Attributes.class "chart__group" ]
  in
  viewDots



-- VIEW / DOT


viewDot : Arguments data -> Group data -> Style -> Data.ScatterChart data -> Svg.Svg msg
viewDot arguments (Group lineConfig) (Style style) =
  Dots.viewForScatter
    { system = arguments.system
    , dotsConfig = arguments.dotsConfig
    , outlier = Outliers.dotConfig arguments.outliersConfig
    , shape = Just lineConfig.shape
    , color = style.color lineConfig.color
    }



-- VIEW / SAMPLE


{-| -}
viewSample : Dots.Config data -> Config data -> Coordinate.System -> Group data -> List (Data.ScatterChart data) -> Float -> Svg.Svg msg
viewSample dotsConfig lineConfig system line data sampleWidth =
  let
    dotPosition =
      Data.Point (sampleWidth / 2) 0
        |> Coordinate.toData system

    color_ =
      color lineConfig line data

    shape_ =
      Just (shape line)
  in
  Svg.g
    [ Attributes.class "chart__sample" ]
    [ Dots.viewSample dotsConfig shape_ color_ system data dotPosition
    ]
