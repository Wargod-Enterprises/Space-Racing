extends RefCounted
## One racing lane: a closed loop around Earth that follows a magnetic field line,
## with a smooth hairpin over each pole.
##
## Every lane shares one progress angle, theta (0 to TAU = one lap), so the same
## theta on two lanes is "the same place" on the track. That's what lets a jump
## land you level with where you left.
##
## theta = 0 is the equator on side A. The lane climbs north, arcs over the north
## pole, comes down side B (the far side of Earth), and passes under the south pole
## back to the start.

## 0 = inner, 1 = middle, 2 = outer.
var level: int
## -1 = left, 0 = center, 1 = right.
var side: int
## How far out this lane crosses the equator, in Earth radii.
var shell_l: float
## Height of the polar hairpin arcs from Earth's center.
var hairpin_radius: float
## Sideways shift that makes the left and right lanes.
var side_offset: Vector3
## Multiplier that makes field strength 1.0 at the strongest point of the inner lane.
var field_scale: float = 1.0
## Length of one full lap of this lane, in units.
var lap_length: float = 0.0


func _init(p_level: int, p_side: int) -> void:
	level = p_level
	side = p_side
	shell_l = Tuning.LANE_L_VALUES[level]
	hairpin_radius = Tuning.EARTH_RADIUS * Tuning.HAIRPIN_RADIUS_FACTORS[level]
	# The loop lies flat in one plane, so "rider's right" is the same (-Z) everywhere.
	side_offset = Vector3(0.0, 0.0, -side * Tuning.LANE_SIDE_SPACING)
	lap_length = _measure_lap_length()


## Distance from Earth's center at this point of the lap.
## Follows the field line r = L * R * cos²(latitude), but never drops below the
## hairpin height. The two are blended with a soft maximum so the joins are smooth.
func radius_at(theta: float) -> float:
	var c := cos(theta)
	var field_line_r := shell_l * Tuning.EARTH_RADIUS * c * c
	var gap := field_line_r - hairpin_radius
	var blend := Tuning.HAIRPIN_BLEND
	return 0.5 * (field_line_r + hairpin_radius + sqrt(gap * gap + blend * blend))


## World position on the lane at this point of the lap.
func position_at(theta: float) -> Vector3:
	var r := radius_at(theta)
	return Vector3(r * cos(theta), r * sin(theta), 0.0) + side_offset


## Direction of travel at this point of the lap.
func forward_at(theta: float) -> Vector3:
	var e := 0.0005
	return (position_at(theta + e) - position_at(theta - e)).normalized()


## Rider orientation here: forward along the lane, up away from Earth's center.
func basis_at(theta: float) -> Basis:
	var forward := forward_at(theta)
	var up := position_at(theta).normalized()
	up = (up - forward * up.dot(forward)).normalized()
	var right := forward.cross(up)
	return Basis(right, up, -forward)


## How many units of track one radian of theta covers here.
## Used to turn the rider's speed into progress; inner lanes cover less ground per lap.
func units_per_radian(theta: float) -> float:
	var e := 0.0005
	return position_at(theta + e).distance_to(position_at(theta - e)) / (2.0 * e)


## Magnetic field strength here (about 1.0 at the inner lane's strongest point).
func field_at(theta: float) -> float:
	return raw_field(position_at(theta)) * field_scale


## Unscaled dipole field strength at any point in space:
## (R / r)³ · sqrt(1 + 3·sin²(latitude)).
static func raw_field(point: Vector3) -> float:
	var r := point.length()
	var sin_lat := point.y / r
	return pow(Tuning.EARTH_RADIUS / r, 3.0) * sqrt(1.0 + 3.0 * sin_lat * sin_lat)


## Magnetic latitude (radians) at this point of the lap: 0 at the equator, ±PI/2 at the poles.
func latitude_at(theta: float) -> float:
	var p := position_at(theta)
	return asin(clampf(p.y / p.length(), -1.0, 1.0))


func _measure_lap_length() -> float:
	var steps := 2048
	var total := 0.0
	var prev := position_at(0.0)
	for i in range(1, steps + 1):
		var p := position_at(TAU * float(i) / steps)
		total += prev.distance_to(p)
		prev = p
	return total
