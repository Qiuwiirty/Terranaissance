shader_type spatial;
uniform sampler2D map;
uniform sampler2D elevation_map;
uniform sampler2D cloud_map;
uniform sampler2D full_cloud_noise_map;
uniform float normalized_sea_level: hint_range(0.0, 1.0); //this is relative 0.0-1.0, calculate the relative of sea level with max sea level
uniform float cloud_alpha;
uniform float band_count = 5.;
uniform vec3 color_band1: source_color = vec3(.75);
uniform vec3 color_band2: source_color = vec3(.5);
vec3 gas_giant(vec2 uv) { //I mean it is not really gas giant, but it kinda look like it
	float noise = texture(full_cloud_noise_map, uv).r;
	
	float distorted_y = uv.y + (noise - 0.5) * 0.1;
	float band = sin(distorted_y * uv.y * band_count * PI);
	
	float mask = smoothstep(-.8, .8, band);
	
	return mix(color_band1, color_band2, mask);
}
void fragment() {
	if (cloud_alpha < 5.)
	{
		float elevation = texture(elevation_map, UV).r;
		float underwater = float(max(elevation, 0.00001) <= normalized_sea_level);
		vec3 land = texture(map, UV).rgb;
		vec3 sea = vec3(0.0, 0.0, 1.0);
		vec2 cloud_uv = UV; cloud_uv.x += TIME * 0.005;
		vec4 cloud = texture(cloud_map, cloud_uv);
		ALBEDO = mix(mix(land, sea, underwater), cloud.rgb, cloud.a * cloud_alpha);
	} else
	{
		ALBEDO = gas_giant(UV);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
