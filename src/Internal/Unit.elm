module Internal.Unit
  exposing
    ( Config, none, years, dollars
    , millimeters, meters, kilometers
    , grams, kilograms
    , custom
    -- INTERNAL
    , view
    )


{-| -}


{-| -}
type Config 
  = Config Properties


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
years : Config
years =
  custom
    { symbol = "y"
    , space = True
    , prefixed = False
    }


{-| -}
dollars : Config
dollars =
  custom
    { symbol = "$"
    , space = False
    , prefixed = True
    }


{-| -}
meters : Config
meters =
  custom
    { symbol = "m"
    , space = True
    , prefixed = False
    }


{-| -}
millimeters : Config
millimeters =
  custom
    { symbol = "mm"
    , space = True
    , prefixed = False
    }


{-| -}
kilometers : Config
kilometers =
  custom
    { symbol = "km"
    , space = True
    , prefixed = False
    }


{-| -}
grams : Config
grams =
  custom
    { symbol = "g"
    , space = True
    , prefixed = False
    }


{-| -}
kilograms : Config
kilograms =
  custom
    { symbol = "kg"
    , space = True
    , prefixed = False
    }


{-| -}
custom : Properties -> Config
custom =
  Config



-- INTERNAL


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

