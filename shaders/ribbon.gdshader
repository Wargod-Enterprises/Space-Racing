// Glowing lane ribbon: bright edges, faint fill, and streaks flowing along the lane.
// UV.x runs -1..1 across the ribbon, UV.y is field strength, UV2.x is distance along the lane.
shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_draw_never;

uniform vec3 lane_color : source_color = vec3(0.25, 0.85, 1.0);
uniform float glow_min = 0.5;      // brightness where the field is weakest
uniform float glow_max = 2.5;      // brightness where the field is strongest
uniform float highlight = 0.0;     // 0..1, raised on the rider's current lane
uniform float streak_speed = 30.0;
uniform float streak_spacing = 12.0;

void fragment() {
	float across = abs(UV.x);
	float strength = clamp(UV.y, 0.0, 1.0);
	float brightness = mix(glow_min, glow_max, sqrt(strength));

	float edge_line = smoothstep(0.65, 0.9, across) * (1.0 - smoothstep(0.92, 1.0, across));
	float fill = 0.18 * (1.0 - smoothstep(0.8, 1.0, across));
	float streak = pow(0.5 + 0.5 * sin((UV2.x - TIME * streak_speed) * TAU / streak_spacing), 12.0);
	streak *= 0.35 * (1.0 - across);

	float shape = edge_line + fill + streak;
	ALBEDO = lane_color * brightness * shape * (1.0 + highlight * 1.5);
}
