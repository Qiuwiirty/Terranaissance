extends Node3D
class_name PlanetRender
@onready var planet_mat : Material = $PlanetMesh.mesh.material
@onready var atmosphere_mat : Material = $AtmosphereMesh.mesh.material
@onready var atmosphere : MeshInstance3D = $AtmosphereMesh
@export var planet_properties: PlanetProperties
@export var terraform_properties: TerraformProperties
@export var cities: Array[City]
@export var biomass_color: Color:
	set(value):
		biomass_color = value
		planet_mat.set_shader_parameter("biomass_color", biomass_color)
func init_planet_properties() -> void:
	_define_biomass_color()
	rotation_degrees.z = planet_properties.axial_tilt
	Game.sun.sun_container.rotation_degrees.x = planet_properties.orbital_tilt
	planet_mat.set_shader_parameter("map", planet_properties.map)
	planet_mat.set_shader_parameter("elevation_map", planet_properties.elevation_map)
	update_appearance()
	planet_properties.init_stuff()
	prepare_gas_giant_appearance()
func _define_biomass_color() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = planet_properties.name.hash()
	var biomass_colors := Sun.sun_to_biomass_colors[Game.sun.star_type]
	biomass_color = biomass_colors[rng.randi_range(0, biomass_colors.size() - 1)]
func update_appearance() -> void:
	update_cities_light()
	planet_mat.set_shader_parameter("normalized_sea_level", terraform_properties.water / planet_properties.max_elevation)
	planet_mat.set_shader_parameter("biomass_coverage", terraform_properties.biomass / planet_properties.max_biomass)
	planet_mat.set_shader_parameter("normalized_temperature", (terraform_properties.temperature - planet_properties.TEMPERATURE_REQUIREMENT) / 5000.)
	planet_mat.set_shader_parameter("cloud_alpha", terraform_properties.pressure / 100000)
	planet_mat.set_shader_parameter("ice_coverage", terraform_properties.ice / planet_properties.max_elevation)
	if terraform_properties.pressure > 0 and terraform_properties.pressure < 500000:
		atmosphere.show()
		atmosphere_mat.set_shader_parameter("atmosphere_strength", terraform_properties.pressure / 100000)
		atmosphere_mat.set_shader_parameter("atmosphere_color", terraform_properties.atmosphere_composition.get_atmosphere_color())
	else:
		atmosphere.hide()
func update_cities_light() -> void:
	#x, y = position. z = size of the city light
	var cities_light : PackedVector3Array
	for city in cities:
		var uv := Game.lat_lon_to_uv(Vector2(city.geoposition.x, city.geoposition.y))
		cities_light.append(Vector3(
			-uv.x,
			uv.y,
			sqrt(city.properties.population) * 0.001
		))
	cities_light.resize(100)
	planet_mat.set_shader_parameter("cities", cities_light)
func prepare_gas_giant_appearance() -> void: #Not actually turning into gas giant but the appearance look like gas giant
	#Might be an overkill just to create gas giant cloud, but i don't care lol (also: it adds variety :D )
	var frequency_curve : Curve = load("uid://chkym846di8e3")
	var rng := RandomNumberGenerator.new()
	rng.seed = planet_properties.name.hash()
	var new_noise_tex := NoiseTexture2D.new()
	var new_fast_noise_lite := FastNoiseLite.new()
	new_fast_noise_lite.frequency = frequency_curve.sample(randf())
	new_fast_noise_lite.noise_type = rng.randi_range(0, 5) #there five type of it
	new_fast_noise_lite.fractal_type = rng.randi_range(0, 3)
	new_fast_noise_lite.domain_warp_enabled = rng.randi()
	new_fast_noise_lite.domain_warp_type = rng.randi_range(0, 2)
	new_noise_tex.noise = new_fast_noise_lite
	planet_mat.set_shader_parameter("full_cloud_noise_map", new_noise_tex)
	planet_mat.set_shader_parameter("color_band1", planet_properties.representative_color)
	planet_mat.set_shader_parameter("color_band2", planet_properties.representative_color * 0.7)
