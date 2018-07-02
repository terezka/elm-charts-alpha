module ScatterChart.Unit exposing (Config, Properties, none, year, dollar, millimeter, meter, kilometer, gram, kilogram, custom)


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
year : Config
year =
  Internal.Unit.year


{-| -}
dollar : Config
dollar =
  Internal.Unit.dollar


{-| -}
meter : Config
meter =
  Internal.Unit.meter


{-| -}
millimeter : Config
millimeter =
  Internal.Unit.millimeter


{-| -}
kilometer : Config
kilometer =
  Internal.Unit.kilometer


{-| -}
gram : Config
gram =
  Internal.Unit.gram


{-| -}
kilogram : Config
kilogram =
  Internal.Unit.kilogram


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

