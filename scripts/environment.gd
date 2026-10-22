extends Node3D
## Builds the space around the race: Earth, its atmosphere glow, the starfield,
## the sun, and the glow effect that makes the lanes bloom.


func _ready() -> void:
	_build_sky_and_glow()
	_build_sun()
	_build_earth()


## Dark starry sky plus the glow (bloom) effect.
func _build_sky_and_glow() -> void:
	var sky_material := ShaderMaterial.new()
	sky_material.shader = load("res://shaders/starfield.gdshader")
	var sky := Sky.new()
	sky.sky_material = sky_material

	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	# Faint fill light so Earth's night side isn't pitch black.
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.06, 0.07, 0.10)
	env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	# Bloom: anything brighter than white glows.
	env.glow_enabled = true
	env.glow_intensity = Tuning.GLOW_INTENSITY
	env.glow_bloom = 0.05
	env.glow_hdr_threshold = 1.0
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE

	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)


## One directional light acting as the sun.
func _build_sun() -> void:
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(Tuning.SUN_ANGLE_DEGREES.x, Tuning.SUN_ANGLE_DEGREES.y, 0.0)
	sun.light_energy = Tuning.SUN_ENERGY
	add_child(sun)


## Earth sphere with oceans, continents and ice caps, plus a soft atmosphere rim.
func _build_earth() -> void:
	var r: float = Tuning.EARTH_RADIUS

	var earth_mesh := SphereMesh.new()
	earth_mesh.radius = r
	earth_mesh.height = r * 2.0
	earth_mesh.radial_segments = 128
	earth_mesh.rings = 64
	var earth_material := ShaderMaterial.new()
	earth_material.shader = load("res://shaders/earth.gdshader")
	var earth := MeshInstance3D.new()
	earth.name = "Earth"
	earth.mesh = earth_mesh
	earth.material_override = earth_material
	add_child(earth)

	var atmo_r: float = r + Tuning.ATMOSPHERE_THICKNESS
	var atmo_mesh := SphereMesh.new()
	atmo_mesh.radius = atmo_r
	atmo_mesh.height = atmo_r * 2.0
	atmo_mesh.radial_segments = 96
	atmo_mesh.rings = 48
	var atmo_material := ShaderMaterial.new()
	atmo_material.shader = load("res://shaders/atmosphere.gdshader")
	var atmosphere := MeshInstance3D.new()
	atmosphere.name = "Atmosphere"
	atmosphere.mesh = atmo_mesh
	atmosphere.material_override = atmo_material
	add_child(atmosphere)
