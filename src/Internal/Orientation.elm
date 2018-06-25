module Internal.Orientation exposing (Config(..), chooses)


{-| -}
type Config
  = Horizontal
  | Vertical


{-| -}
chooses : Config -> { horizontal : a, vertical : a } -> a
chooses config choices =
    case config of
        Horizontal -> choices.horizontal
        Vertical -> choices.vertical
