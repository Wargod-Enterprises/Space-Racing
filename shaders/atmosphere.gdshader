// Soft blue halo around Earth's edge.
shader_type spatial;
render_mode unshaded, blend_add, cull_back, depth_draw_never;

uniform vec3 rim_color : source_color = vec3(0.3, 0.6, 1.0);
uniform float strength = 1.4;

void fragment() {
	float edge = 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	// Brightest just inside the rim, fading out at the very edge so there's no hard line.
	float glow = pow(edge, 3.0) * smoothstep(1.0, 0.8, edge);
	ALBEDO = rim_color * glow * strength;
}
