// Dark space with scattered stars of varying brightness.
shader_type sky;

uniform vec3 space_color : source_color = vec3(0.004, 0.005, 0.012);
uniform float star_density = 0.004;   // fraction of sky cells that hold a star
uniform float star_scale = 260.0;     // bigger = smaller, more numerous cells

float hash(vec3 p) {
	p = fract(p * 0.3183099 + vec3(0.11, 0.17, 0.13));
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

void sky() {
	vec3 g = EYEDIR * star_scale;
	vec3 cell = floor(g);
	vec3 offset = fract(g) - 0.5;
	float pick = hash(cell);
	float star = 0.0;
	if (pick > 1.0 - star_density) {
		float brightness = hash(cell + vec3(7.0, 3.0, 1.0));
		star = smoothstep(0.45, 0.0, length(offset)) * mix(0.3, 2.2, brightness * brightness);
	}
	vec3 tint = mix(vec3(0.8, 0.85, 1.0), vec3(1.0, 0.9, 0.75), hash(cell + vec3(2.0)));
	COLOR = space_color + tint * star;
}
