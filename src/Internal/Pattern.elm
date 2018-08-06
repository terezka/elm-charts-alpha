module Internal.Pattern exposing (Config, Properties, default, custom, toDefs)


{-| -}

import Svg
import Svg.Attributes


{-| -}
type Config =
    Config (Properties)


{-| -}
type alias Properties =
    { stroke : Int
    , space : Int
    }


{-| -}
default : Config
default =
  Config
    { stroke = 3
    , space = 2
    }


{-| -}
custom : Int -> Int -> Config
custom stroke space =
  Config
    { stroke = stroke
    , space = space
    }


{-| -}
toDefs : Config -> List (Svg.Svg msg)
toDefs (Config config) =
  let
    space =
      config.stroke + config.space
  in
  [ Svg.pattern
    [ Svg.Attributes.id "pattern-stripe"
    , Svg.Attributes.patternUnits "userSpaceOnUse"
    , Svg.Attributes.width (toString space)
    , Svg.Attributes.height (toString space)
    , Svg.Attributes.patternTransform "rotate(45)"
    ]
    [ Svg.rect
        [ Svg.Attributes.width (toString config.stroke)
        , Svg.Attributes.height (toString space)
        , Svg.Attributes.transform "translate(0,0)"
        , Svg.Attributes.fill "white"
        ]
        []
    ]
  , Svg.mask
      [ Svg.Attributes.id "mask-stripe" ]
      [ Svg.rect
          [ Svg.Attributes.x "-10%"
          , Svg.Attributes.y "-10%"
          , Svg.Attributes.width "110%"
          , Svg.Attributes.height "110%"
          , Svg.Attributes.fill "url(#pattern-stripe)"
          ]
          []
      ]
  ]
