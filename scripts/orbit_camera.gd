extends Camera3D
## Free-look camera that circles Earth so you can inspect the track.
## Drag with the mouse or use the arrow keys to orbit; mouse wheel or Q / E to zoom.

## Turn around Earth's axis (radians).
var yaw: float = 0.45
## Height above the equator plane (radians).
var pitch: float = 0.3
## Distance from Earth's center.
var distance: float = Tuning.ORBIT_START_DISTANCE


func _ready() -> void:
	near = 0.5
	far = 6000.0
	fov = 60.0
	current = true
	_update_transform()


func _unhandled_input(event: InputEvent) -> void:
	# Drag with any mouse button held to orbit.
	if event is InputEventMouseMotion and event.button_mask != 0:
		yaw -= event.relative.x * Tuning.ORBIT_MOUSE_SENSITIVITY
		pitch += event.relative.y * Tuning.ORBIT_MOUSE_SENSITIVITY
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance *= 0.9
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance *= 1.1


func _process(delta: float) -> void:
	var turn := Tuning.ORBIT_KEY_SPEED * delta
	if Input.is_key_pressed(KEY_LEFT):
		yaw -= turn
	if Input.is_key_pressed(KEY_RIGHT):
		yaw += turn
	if Input.is_key_pressed(KEY_UP):
		pitch += turn
	if Input.is_key_pressed(KEY_DOWN):
		pitch -= turn
	if Input.is_key_pressed(KEY_Q):
		distance *= 1.0 - delta
	if Input.is_key_pressed(KEY_E):
		distance *= 1.0 + delta
	_update_transform()


## Place the camera on a sphere around Earth and look at the center.
func _update_transform() -> void:
	pitch = clampf(pitch, deg_to_rad(-89.0), deg_to_rad(89.0))
	distance = clampf(distance, Tuning.ORBIT_MIN_DISTANCE, Tuning.ORBIT_MAX_DISTANCE)
	var dir := Vector3(cos(pitch) * sin(yaw), sin(pitch), cos(pitch) * cos(yaw))
	position = dir * distance
	look_at(Vector3.ZERO, Vector3.UP)
