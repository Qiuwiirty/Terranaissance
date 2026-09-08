shader_type spatial;

uniform vec3 atmosphere_color : source_color = vec3(0.2, 0.5, 1.0);
uniform float atmosphere_strength = 2.0;
uniform float atmosphere_power = 4.0;

void fragment() {
	ALBEDO = atmosphere_color;
}

void light() {
	float sunlight = dot(LIGHT, NORMAL);
	float facing = abs(dot(normalize(NORMAL), normalize(VIEW)));
	
	float rim = pow(1.0 - facing, atmosphere_power);

	DIFFUSE_LIGHT = vec3(sunlight);
	ALPHA = rim;
}
