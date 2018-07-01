module Internal.Chart exposing (Arguments, view)


import Html
import Svg
import Svg.Attributes
import Internal.Coordinate
import Internal.Container
import Internal.Legends
import Internal.Axis
import Internal.Axis.Intersection
import Internal.Utils
import Internal.Events
import Internal.Legends
import Internal.Grid
import Internal.Data
import Internal.Junk
import Internal.Utils


{-| -}
type alias Arguments chart value data msg =
  { container : Internal.Container.Config msg
  , events : Internal.Events.Config chart data msg
  , defs : List (Svg.Svg msg)
  , grid : Internal.Grid.Config
  , series : Svg.Svg msg
  , intersection : Internal.Axis.Intersection.Config
  , horizontalAxis : Internal.Axis.Config Float data msg
  , verticalAxis : Internal.Axis.Config value data msg
  , legends : Internal.Legends.Arguments msg
  , trends : Svg.Svg msg
  , junk : Internal.Junk.Layers msg
  }


{-| -}
view : Arguments chart value data msg -> List (Internal.Data.Data chart data) -> Internal.Coordinate.System -> Html.Html msg
view args data system =
  let withSystem = List.map (Internal.Utils.apply system)

      -- Chart sizing and positioning
      chartSizeAndPosition =
        [ Svg.Attributes.x (toString system.frame.margin.left)
        , Svg.Attributes.y (toString system.frame.margin.top)
        , Svg.Attributes.width (toString (Internal.Coordinate.lengthX system))
        , Svg.Attributes.height (toString (Internal.Coordinate.lengthY system))
        ]

      -- Junk
      junkBelow = Svg.g [ Svg.Attributes.class "chart__junk--below" ] (withSystem args.junk.below)
      junkAbove = Svg.g [ Svg.Attributes.class "chart__junk--above" ] (withSystem args.junk.above)

      -- Defs
      defs =
        let chartAreaCut =
              Svg.clipPath
                [ Svg.Attributes.id (Internal.Utils.toChartAreaId system.id) ]
                [ Svg.rect chartSizeAndPosition [] ]
        in Svg.defs [] (chartAreaCut :: args.defs)

      -- Chart components
      grid = Internal.Grid.view (Internal.Axis.ticks args.horizontalAxis) (Internal.Axis.ticks args.verticalAxis) args.grid system
      horizontalAxis = Internal.Axis.viewHorizontal system args.intersection args.horizontalAxis
      verticalAxis = Internal.Axis.viewVertical system args.intersection args.verticalAxis
      legends = Internal.Legends.view args.legends

      -- Overlay
      eventCatcher =
        let attributes =
              [ [ Svg.Attributes.fill "transparent" ]
              , chartSizeAndPosition
              , Internal.Events.toChartAttributes data system args.events
              ]
        in Svg.rect (List.concat attributes) []

      -- Containers
      innerContainer =
        let attributes =
              [ Internal.Container.properties .attributesSvg args.container
              , Internal.Events.toContainerAttributes data system args.events
              , [ Svg.Attributes.viewBox ("0 0 " ++ toString system.frame.size.width ++ " " ++ toString system.frame.size.height) ]
              ]
        in Svg.svg (List.concat attributes)

      container chart =
        let attributes =
              [ Internal.Container.properties .attributesHtml args.container
              , [ Internal.Container.styles args.container system ]
              ]
        in Html.div (List.concat attributes) (innerContainer chart :: withSystem args.junk.html)
  in
  container
    [ defs
    , grid
    , junkBelow
    , args.series
    , eventCatcher
    , horizontalAxis
    , verticalAxis
    , legends
    , args.trends
    , junkAbove
    ]


