shader_type spatial;
uniform sampler2D map;
uniform sampler2D elevation_map;
uniform float normalized_sea_level: hint_range(0.0, 1.0); //this is relative 0.0-1.0, calculate the relative of sea level with max sea level
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float elevation = texture(elevation_map, UV).r;
	float underwater = float(max(elevation, 0.00001) <= normalized_sea_level);

	vec3 land = texture(map, UV).rgb;
	vec3 sea = vec3(0.0, 0.0, 1.0);

	ALBEDO = mix(land, sea, underwater);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
