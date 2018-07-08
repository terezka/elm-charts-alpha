module Chart.Orientation exposing (Config, default, vertical, horizontal)

{-| @docs Config, default, vertical, horizontal -}

import Internal.Orientation


{-| -}
type alias Config =
  Internal.Orientation.Config


{-| -}
vertical : Config
vertical =
  Internal.Orientation.Vertical


{-| -}
horizontal : Config
horizontal =
  Internal.Orientation.Horizontal


{-| -}
default : Config
default =
  Internal.Orientation.Vertical -- TODO Flip vertical and horizontal
  -- TODO Move to Internal.
