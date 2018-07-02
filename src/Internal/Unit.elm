module Internal.Unit
  exposing
    ( Config, none, year, dollar
    , millimeter, meter, kilometer
    , gram, kilogram
    , custom
    -- INTERNAL
    , view
    )


{-| -}


{-| -}
type Config =
  Config Properties


{-| -}
type alias Properties =
  { symbol : String
  , space : Bool
  , prefixed : Bool
  }


{-| -}
none : Config
none =
  custom
    { symbol = ""
    , space = False
    , prefixed = False
    }


{-| -}
year : Config
year =
  custom
    { symbol = "y"
    , space = True
    , prefixed = False
    }


{-| -}
dollar : Config
dollar =
  custom
    { symbol = "$"
    , space = False
    , prefixed = True
    }


{-| -}
meter : Config
meter =
  custom
    { symbol = "m"
    , space = True
    , prefixed = False
    }


{-| -}
millimeter : Config
millimeter =
  custom
    { symbol = "mm"
    , space = True
    , prefixed = False
    }


{-| -}
kilometer : Config
kilometer =
  custom
    { symbol = "km"
    , space = True
    , prefixed = False
    }


{-| -}
gram : Config
gram =
  custom
    { symbol = "g"
    , space = True
    , prefixed = False
    }


{-| -}
kilogram : Config
kilogram =
  custom
    { symbol = "kg"
    , space = True
    , prefixed = False
    }


{-| -}
custom : Properties -> Config
custom =
  Config


{-| -}
view : Config -> Float -> String
view (Config config) n =
  let space = if config.space then " " else ""
      number = toString n
  in
  if config.prefixed then
    config.symbol ++ space ++ number
  else
    number ++ space ++ config.symbol

