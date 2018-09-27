..

-- Axis
type alias Config value data msg
default : String -> Unit.Config -> (data -> value) -> Config value data msg
full : String -> Unit.Config -> (data -> value) -> Config value data msg
time : String -> Unit.Config -> (data -> value) -> Config value data msg
custom :
  { title : Title.Config msg
  , unit : Unit.Config
  , variable : data -> value
  , range : Range.Config
  , line : AxisLine.Config msg
  , ticks : Ticks.Config msg
  } -> Config value data msg


-- Axis.Dependent
default : String -> Unit.Config -> Config msg
custom :
  { title : Title.Config msg
  , unit : Unit.Config
  , range : Range.Config
  , line : AxisLine.Config msg
  , ticks : Ticks.Config msg
  } -> Config msg

-- Axis.Independent
default : String -> (data -> String) -> Config data msg
custom :
  { title : Title.Config msg
  , range : Range.Config
  , line : AxisLine.Config msg
  , label : data -> String
  , tick : Tick.Config msg
  } -> Config data msg


-- Axis.Tick
int : Config msg
float : Config msg
gridless : Config msg
opposite : Config msg
long : Config msg
type alias Time
type Unit
time : Config msg
format : Time -> String
type alias Direction
negative : Direction
positive : Direction
custom :
  { color : Color.Color
  , width : Float
  , length : Float
  , grid : Bool
  , direction : Direction
  , label : String -> Svg msg
  }
  -> Config msg



-- Axis.Line
type alias Config msg
default : Config msg
full : Color.Color -> Config msg
rangeFrame : Color.Color -> Config msg
none : Config msg


-- Axis.Range
type alias Config
default : Config
padded : Float -> Float -> Config
window : Float -> Float -> Config
custom : (Coordinate.Range -> Coordinate.Range) -> Config



-- Axis.Intersection
type alias Config
default : Config
atOrigin : Config
at : Float -> Float -> Config
custom : (Coordinate.Range -> Float) -> (Coordinate.Range -> Float) -> Config


-- Axis.Ticks
type alias Config msg
type alias Set msg
default : Config msg
int : Int -> Config msg
time : Int -> Config msg
float : Int -> Config msg
intCustom : Tick.Config msg -> Int -> Config msg
floatCustom : Tick.Config msg -> Int -> Config msg
timeCustom : Tick.Config msg -> Int -> Config msg




-- Axis.Values
around : Int -> Amount
exactly : Int -> Amount
int : Amount -> Coordinate.Range -> List Int
float : Amount -> Coordinate.Range -> List Float
custom : Float -> Float -> Coordinate.Range -> List Float
time : Int -> Coordinate.Range -> List Tick.Time


-- Axis.Unit
none : Config
years : Config
...
