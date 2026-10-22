extends Node3D
## Builds the 9 lanes (3 altitude levels x 3 side-by-side positions)
## and a glowing ribbon for each one.

const Lane := preload("res://scripts/lane.gd")
const RIBBON_SHADER := preload("res://shaders/ribbon.gdshader")
const SIDES: Array[int] = [-1, 0, 1]

## All 9 lanes. Use get_lane() rather than indexing directly.
var lanes: Array[Lane] = []
## Ribbon material for each lane, same order as `lanes`.
var ribbon_materials: Array[ShaderMaterial] = []


func _ready() -> void:
	for level in 3:
		for side in SIDES:
			lanes.append(Lane.new(level, side))
	_normalize_field_strength()
	for lane in lanes:
		_build_path(lane)
		_build_ribbon(lane)


## level: 0 inner, 1 middle, 2 outer. side: -1 left, 0 center, 1 right.
## Returns null if there's no lane there (e.g. trying to go above the outer level).
func get_lane(level: int, side: int) -> Lane:
	if level < 0 or level > 2 or side < -1 or side > 1:
		return null
	return lanes[level * 3 + side + 1]


## Scale field strength so the strongest point of the inner center lane is 1.0.
func _normalize_field_strength() -> void:
	var inner := get_lane(0, 0)
	var strongest := 0.0
	for i in 4096:
		strongest = maxf(strongest, Lane.raw_field(inner.position_at(TAU * float(i) / 4096.0)))
	for lane in lanes:
		lane.field_scale = 1.0 / strongest


## A Path3D holding the lane's curve, for inspecting in the editor's Remote tree.
func _build_path(lane: Lane) -> void:
	var curve := Curve3D.new()
	var points := 720
	for i in points + 1:
		curve.add_point(lane.position_at(TAU * float(i) / points))
	var path := Path3D.new()
	path.name = "LanePath_%d_%d" % [lane.level, lane.side + 1]
	path.curve = curve
	add_child(path)


## A flat glowing strip along the lane. Brighter where the field is stronger.
func _build_ribbon(lane: Lane) -> void:
	var segments: int = Tuning.RIBBON_SEGMENTS
	var half_width: float = Tuning.RIBBON_WIDTH * 0.5
	var verts := PackedVector3Array()
	var uvs := PackedVector2Array()      # x: -1..1 across the ribbon, y: field strength
	var uv2s := PackedVector2Array()     # x: distance along the lane (for moving streaks)
	var indices := PackedInt32Array()

	var distance := 0.0
	var prev := lane.position_at(0.0)
	for i in segments + 1:
		var theta := TAU * float(i) / segments
		var p := lane.position_at(theta)
		distance += prev.distance_to(p)
		prev = p
		var right := lane.basis_at(theta).x
		var strength := lane.field_at(theta)
		verts.append(p - right * half_width)
		verts.append(p + right * half_width)
		uvs.append(Vector2(-1.0, strength))
		uvs.append(Vector2(1.0, strength))
		uv2s.append(Vector2(distance, 0.0))
		uv2s.append(Vector2(distance, 0.0))
		if i < segments:
			var a := i * 2
			indices.append_array([a, a + 1, a + 2, a + 1, a + 3, a + 2])

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_TEX_UV2] = uv2s
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	var material := ShaderMaterial.new()
	material.shader = RIBBON_SHADER
	material.set_shader_parameter("lane_color", Tuning.RIBBON_COLORS[lane.level])
	material.set_shader_parameter("glow_min", Tuning.RIBBON_GLOW_MIN)
	material.set_shader_parameter("glow_max", Tuning.RIBBON_GLOW_MAX)
	ribbon_materials.append(material)

	var ribbon := MeshInstance3D.new()
	ribbon.name = "Ribbon_%d_%d" % [lane.level, lane.side + 1]
	ribbon.mesh = mesh
	ribbon.material_override = material
	add_child(ribbon)
