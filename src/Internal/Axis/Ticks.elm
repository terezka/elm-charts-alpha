module Internal.Axis.Ticks exposing
  ( Config, Set
  , default, custom, set
  -- INTERNAL
  , Compiled, ticks
  )


import Internal.Axis.Tick as Tick
import Internal.Coordinate as Coordinate



-- AXIS


{-| -}
type Config msg
  = Config (Coordinate.Range -> Coordinate.Range -> List (Set msg))


{-| -}
type Set msg =
  Set (Tick.Config msg) (List ( Float, String ))


-- API


{-| -}
default : Config msg
default =
  custom (\_ _ -> []) -- TODO


{-| -}
custom : (Coordinate.Range -> Coordinate.Range -> List (Set msg)) -> Config msg
custom =
  Config


{-| -}
set : Tick.Config msg -> (data -> String) -> (data -> Float) -> List data -> Set msg
set config format position data =
  let ticks d = ( position d, format d ) in
  Set config (List.map ticks data)



-- INTERNAL


{-| -}
type alias Compiled msg =
  { position : Float
  , label : String
  , config : Tick.Properties msg
  }


{-| -}
ticks : Coordinate.Range -> Coordinate.Range -> Config msg -> List (Compiled msg)
ticks dataRange range (Config toSets) =
  let eachTick config ( p, l ) = Compiled p l (Tick.properties config)
      eachSet (Set config ticks) = List.map (eachTick config) ticks
  in
  List.map eachSet (toSets dataRange range)
    |> List.concat
