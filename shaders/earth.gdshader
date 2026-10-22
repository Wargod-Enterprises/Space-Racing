// Simple Earth: blue oceans, green continents, white ice caps. Continents come from noise.
shader_type spatial;

uniform vec3 ocean_color : source_color = vec3(0.04, 0.16, 0.42);
uniform vec3 land_color : source_color = vec3(0.13, 0.36, 0.13);
uniform vec3 ice_color : source_color = vec3(0.88, 0.92, 0.97);
uniform float land_amount = 0.53;  // higher = less land

varying vec3 local_pos;

float hash(vec3 p) {
	p = fract(p * 0.3183099 + vec3(0.1));
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float noise(vec3 x) {
	vec3 i = floor(x);
	vec3 f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(mix(hash(i), hash(i + vec3(1, 0, 0)), f.x),
				   mix(hash(i + vec3(0, 1, 0)), hash(i + vec3(1, 1, 0)), f.x), f.y),
			   mix(mix(hash(i + vec3(0, 0, 1)), hash(i + vec3(1, 0, 1)), f.x),
				   mix(hash(i + vec3(0, 1, 1)), hash(i + vec3(1, 1, 1)), f.x), f.y), f.z);
}

float fbm(vec3 p) {
	float total = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 5; i++) {
		total += noise(p) * amp;
		p *= 2.03;
		amp *= 0.5;
	}
	return total;
}

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	vec3 n = normalize(local_pos);
	float h = fbm(n * 2.5 + vec3(3.1, 1.7, 5.3));
	float land = smoothstep(land_amount - 0.01, land_amount + 0.02, h);
	vec3 col = mix(ocean_color, land_color * (0.8 + 0.4 * fbm(n * 9.0)), land);
	float ice = smoothstep(0.9, 0.94, abs(n.y) + (h - 0.5) * 0.25);
	col = mix(col, ice_color, ice);
	ALBEDO = col;
	ROUGHNESS = mix(0.6, 0.95, max(land, ice));
	SPECULAR = mix(0.3, 0.1, land);
}
