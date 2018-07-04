module LineChart.Axis.Unit exposing (Config, Properties, none, years, dollars, millimeters, meters, kilometers, grams, kilograms, custom)


{-| -}
import Internal.Unit


{-| -}
type alias Config =
  Internal.Unit.Config


{-| -}
none : Config
none =
  Internal.Unit.none


{-| -}
years : Config
years =
  Internal.Unit.years


{-| -}
dollars : Config
dollars =
  Internal.Unit.dollars


{-| -}
meters : Config
meters =
  Internal.Unit.meters


{-| -}
millimeters : Config
millimeters =
  Internal.Unit.millimeters


{-| -}
kilometers : Config
kilometers =
  Internal.Unit.kilometers


{-| -}
grams : Config
grams =
  Internal.Unit.grams


{-| -}
kilograms : Config
kilograms =
  Internal.Unit.kilograms



{-| -}
type alias Properties =
  { symbol : String
  , space : Bool
  , prefixed : Bool
  }


{-| -}
custom : Properties -> Config
custom =
  Internal.Unit.custom

