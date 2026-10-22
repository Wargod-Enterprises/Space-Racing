extends Node
## Every tunable number in Space Racing lives here.
## Change a value, save the file, and press F5 to try it.

# --- World ---------------------------------------------------------------

## Radius of Earth, in game units. Everything else is scaled from this.
var EARTH_RADIUS: float = 100.0
## How far the soft blue glow around Earth reaches past the surface.
var ATMOSPHERE_THICKNESS: float = 4.0
## Sun direction as (tilt down, turn around) in degrees.
var SUN_ANGLE_DEGREES: Vector2 = Vector2(-20.0, 40.0)
## Sun brightness.
var SUN_ENERGY: float = 1.3
## How strongly bright things (ribbons, stars) bloom.
var GLOW_INTENSITY: float = 0.9

# --- Track: the 3 x 3 lane grid -------------------------------------------

## Shell value L for each altitude level (inner, middle, outer).
## L = how far out the lane crosses the equator, in Earth radii.
var LANE_L_VALUES: Array[float] = [1.4, 1.9, 2.6]
## Hairpin height over each pole, as a multiple of Earth's radius (inner, middle, outer).
## Lanes bunch together here; keep these a few units apart so lanes never touch.
var HAIRPIN_RADIUS_FACTORS: Array[float] = [1.06, 1.12, 1.20]
## Sideways gap between the left, center and right lanes.
var LANE_SIDE_SPACING: float = 8.0
## How gently a field line bends into its polar hairpin. Bigger = softer, wider corner.
var HAIRPIN_BLEND: float = 20.0

# --- Track visuals ----------------------------------------------------------

## Width of each glowing lane ribbon.
var RIBBON_WIDTH: float = 3.0
## How many slices each ribbon is built from (more = smoother curves).
var RIBBON_SEGMENTS: int = 1440
## Ribbon color for each altitude level (inner, middle, outer).
var RIBBON_COLORS: Array[Color] = [
	Color(0.25, 0.85, 1.0),
	Color(0.35, 1.0, 0.55),
	Color(0.85, 0.45, 1.0),
]
## Ribbon brightness where the field is weakest / strongest.
var RIBBON_GLOW_MIN: float = 0.5
var RIBBON_GLOW_MAX: float = 2.5

# --- Inspection camera (milestone 1) ---------------------------------------

## Starting distance of the orbit camera from Earth's center.
var ORBIT_START_DISTANCE: float = 650.0
## Closest / farthest the orbit camera can zoom.
var ORBIT_MIN_DISTANCE: float = 115.0
var ORBIT_MAX_DISTANCE: float = 2000.0
## Orbit speed for mouse drag and keys.
var ORBIT_MOUSE_SENSITIVITY: float = 0.005
var ORBIT_KEY_SPEED: float = 1.5
