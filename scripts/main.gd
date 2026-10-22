extends Node3D
## Root of the game. Builds the world, the track and the camera when the game starts.

const SpaceEnvironment := preload("res://scripts/environment.gd")
const Track := preload("res://scripts/track.gd")
const OrbitCamera := preload("res://scripts/orbit_camera.gd")

var track: Track


func _ready() -> void:
	# Earth, stars, sun and glow.
	var world := SpaceEnvironment.new()
	world.name = "SpaceEnvironment"
	add_child(world)

	# The 9 glowing lanes.
	track = Track.new()
	track.name = "Track"
	add_child(track)

	# Free-look camera for inspecting the track (milestone 1).
	var cam := OrbitCamera.new()
	cam.name = "OrbitCamera"
	add_child(cam)

	_add_help_text("Drag mouse or arrow keys: orbit    Mouse wheel or Q / E: zoom")
	_run_dev_screenshot(cam)


## Small on-screen reminder of the controls.
func _add_help_text(text: String) -> void:
	var layer := CanvasLayer.new()
	var label := Label.new()
	label.text = text
	label.position = Vector2(16, 12)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0, 0.8))
	layer.add_child(label)
	add_child(layer)


## Developer helper: run with `-- --shot=path.png [--cam=yaw,pitch,distance]`
## to save a screenshot and quit. Does nothing in normal play.
func _run_dev_screenshot(cam: OrbitCamera) -> void:
	var shot_path := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--shot="):
			shot_path = arg.trim_prefix("--shot=")
		elif arg.begins_with("--cam="):
			var parts := arg.trim_prefix("--cam=").split(",")
			if parts.size() == 3:
				cam.yaw = deg_to_rad(parts[0].to_float())
				cam.pitch = deg_to_rad(parts[1].to_float())
				cam.distance = parts[2].to_float()
	if shot_path.is_empty():
		return
	for i in 20:
		await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png(shot_path)
	get_tree().quit()
