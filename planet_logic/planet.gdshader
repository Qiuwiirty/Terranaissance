  shader_type spatial;
uniform sampler2D map;
uniform sampler2D elevation_map;
uniform sampler2D cloud_map;
uniform sampler2D full_cloud_noise_map;
uniform sampler2D city_light_map: filter_nearest;
uniform float normalized_sea_level: hint_range(0.0, 1.0); //this is relative 0.0-1.0, calculate the relative of sea level with max sea level
uniform float cloud_alpha;
uniform float band_count = 5.;
uniform vec3 color_band1: source_color = vec3(.75);
uniform vec3 color_band2: source_color = vec3(.5);

uniform vec3[100] cities; //x, y = position, z = size

uniform vec3 sun_direction = vec3(1.0, 0.0, 0.0);
uniform float sun_active = 1.0;
vec3 gas_giant(vec2 uv) { //I mean it is not really gas giant, but it kinda look like it
	float noise = texture(full_cloud_noise_map, uv).r;
	
	float distorted_y = uv.y + (noise - 0.5) * 0.1;
	float band = sin(distorted_y * uv.y * band_count * PI);
	
	float mask = smoothstep(-.8, .8, band);
	
	return mix(color_band1, color_band2, mask);
}
vec3 uv_to_sphere(vec2 uv) {
	float lon = (uv.x - 0.5) * TAU;
	float lat = (uv.y - 0.5) * PI;
	
	return vec3(
		cos(lat) * cos(lon),
		sin(lat),
		cos(lat) * sin(lon)
		);
}
bool get_underwater(vec2 uv) {
	float elevation = texture(elevation_map, uv).r;
	return max(elevation, 0.00001) <= normalized_sea_level;
}

vec4 get_cloud(vec2 uv) {
	vec2 cloud_uv = uv;
	cloud_uv.x += TIME * 0.005;
	return texture(cloud_map, cloud_uv);
}
void fragment() {
	if (cloud_alpha < 5.)
	{
		vec3 land = texture(map, UV).rgb;
		vec3 sea = vec3(0.0, 0.0, 1.0);
		vec4 cloud = get_cloud(UV);
		vec3 land_sea = mix(land, sea, float(get_underwater(UV)));
		vec3 land_sea_cloud = mix(land_sea, cloud.rgb, cloud.a * cloud_alpha);
		ALBEDO = land_sea_cloud;
		
		vec3 sun_dir_view = (VIEW_MATRIX * vec4(sun_direction, 0.0)).xyz;
		float sunlight = dot(NORMAL, normalize(sun_dir_view));
		float day = smoothstep(-0.2, 0.1, sunlight);
		float night = 1.0;
		
		if (sun_active > 0.5) {
			vec3 sun_dir_view = (VIEW_MATRIX * vec4(sun_direction, 0.0)).xyz;
			float sunlight = dot(NORMAL, normalize(sun_dir_view));
			float day = smoothstep(-0.2, 0.1, sunlight);
			night = 1.0 - day;
		}
		float city_light = 0.0;
		vec3 surface_pos = uv_to_sphere(UV);
		for (int i = 0; i < 100; i++) 
		{
			vec3 city = cities[i];
			vec3 city_pos = uv_to_sphere(city.xy);
			float angle = acos(dot(surface_pos, city_pos));
			float circle =
			1.0 - smoothstep(city.z * 0.8, city.z, angle);
			city_light = max(city_light, circle);
		}
		
		vec3 city_emission =
		texture(city_light_map, UV).rgb * city_light * (1.0 - cloud.a * cloud_alpha) * float(!get_underwater(UV));
		
		EMISSION = city_emission * night;
	} else
	{
		ALBEDO = gas_giant(UV);
	}
	
}