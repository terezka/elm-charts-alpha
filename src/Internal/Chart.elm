module Internal.Chart exposing (Arguments, view)


import Html
import Svg
import Svg.Attributes
import Internal.Orientation
import Internal.Coordinate
import Internal.Container
import Internal.Legends
import Internal.Axis
import Internal.Axis.Intersection
import Internal.Utils
import Internal.Events
import Internal.Legends
import Internal.Grid
import Internal.Point
import Internal.Junk
import Internal.Utils


{-| -}
type alias Arguments element value data msg =
  { container : Internal.Container.Config msg
  , events : Internal.Events.Config element data msg
  , defs : List (Svg.Svg msg)
  , grid : Internal.Grid.Config
  , series : Svg.Svg msg
  , intersection : Internal.Axis.Intersection.Config
  , horizontalAxis : Internal.Axis.Config Float data msg
  , verticalAxis : Internal.Axis.Config value data msg
  , legends : Internal.Legends.Arguments msg
  , trends : Svg.Svg msg
  , junk : Internal.Junk.Layers msg
  , orientation : Internal.Orientation.Config
  }


{-| -}
view : Arguments element value data msg -> List (Internal.Point.Point element data) -> Internal.Coordinate.System -> Html.Html msg
view args data system =
  let withSystem = List.map (Internal.Utils.apply system)
      size = Internal.Container.properties .size args.container

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
      horizontalAxis = Internal.Axis.viewHorizontal system size.width args.intersection args.horizontalAxis
      verticalAxis = Internal.Axis.viewVertical system size.height args.intersection args.verticalAxis
      legends = Internal.Legends.view args.legends
      
      grid =
        Internal.Grid.view
          { width = size.width
          , height = size.height
          , xTicks = Internal.Axis.ticks args.horizontalAxis
          , yTicks = Internal.Axis.ticks args.verticalAxis
          }

      -- Overlay
      eventCatcher =
        let attributes =
              [ [ Svg.Attributes.fill "transparent" ]
              , chartSizeAndPosition
              , Internal.Events.toChartAttributes args.orientation data system args.events
              ]
        in Svg.rect (List.concat attributes) []

      -- Containers
      innerContainer =
        let attributes =
              [ Internal.Container.properties .attributesSvg args.container
              , Internal.Events.toContainerAttributes args.orientation data system args.events
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
    , grid args.grid system
    , junkBelow
    , args.series
    , eventCatcher
    , horizontalAxis
    , verticalAxis
    , legends
    , args.trends
    , junkAbove
    ]


