extends Node3D
class_name Planet
const OXYGEN_GRADIENT: Gradient = preload("uid://w3mrnkqo8pl2")
static var planets_template: Dictionary[String, PlanetProperties]
@onready var tick_timer : Timer = $TickTimer

@export var planet_properties : PlanetProperties
@export var terraform_properties : TerraformProperties = TerraformProperties.new()
@export var terraform_modifier_per_tick : TerraformProperties = TerraformProperties.new()
var cities : Array[City]
var outposts : Array

var biomass_color: Color = Color.GREEN
@onready var mat: Material = $PlanetMesh.mesh.material
@onready var atmosphere : MeshInstance3D = $AtmosphereMesh

var in_creating_city := false
static func _static_init() -> void:
	var mars := PlanetProperties.new()
	mars.name = "Mars"
	mars.radius = 3389.5 #in km btw
	mars.axial_tilt = 25.19
	mars.orbital_tilt = 1.85
	mars.max_elevation = 2150000
	
	mars.starting_terraform_properties.pressure = 610
	mars.starting_terraform_properties.oxygen = 1520
	mars.map = load("uid://bsas3wag8j7cs")
	mars.elevation_map = load("uid://c5v61glibq5lm")
	planets_template["mars"] = mars
func _enter_tree() -> void:
	Game.planet = self
func _ready() -> void:
	planet_properties = planets_template["mars"]
	start()
	
func _process(_delta: float) -> void:
	if Game.sun.light_energy == 0: mat.set_shader_parameter("sun_active", false); return
	if Game.sun.rotate_light:
		mat.set_shader_parameter("sun_active", true)
		var sun_dir: Vector3 = Game.sun.global_transform.basis.z
		mat.set_shader_parameter("sun_direction", sun_dir)
func _on_update_tick() -> void:
	terraform_properties.add(terraform_modifier_per_tick)
	update_appearance()
func _define_biomass_color() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = planet_properties.name.hash()
	var biomass_colors := Sun.sun_to_biomass_colors[Game.sun.star_type]
	biomass_color = biomass_colors[rng.randi_range(0, biomass_colors.size() - 1)]
func start() -> void: #Intended for starting a new world. Which expect everything to be empty so it will override some things (which can definetly reset the data so use carefully)
	terraform_properties = planet_properties.starting_terraform_properties
	init_planet_properties()
func init_planet_properties() -> void:
	_define_biomass_color()
	rotation_degrees.z = planet_properties.axial_tilt
	Game.sun.sun_container.rotation_degrees.x = planet_properties.orbital_tilt
	mat.set_shader_parameter("map", planet_properties.map)
	mat.set_shader_parameter("elevation_map", planet_properties.elevation_map)
	mat.set_shader_parameter("biomass_color", biomass_color)
	update_appearance()
	planet_properties.init_stuff()
	prepare_gas_giant_appearance()
func update_appearance() -> void:
	update_cities_light()
	mat.set_shader_parameter("normalized_sea_level", terraform_properties.water / planet_properties.max_elevation)
	mat.set_shader_parameter("biomass_coverage", terraform_properties.biomass / planet_properties.max_biomass)
	mat.set_shader_parameter("normalized_temperature", (terraform_properties.temperature - planet_properties.TEMPERATURE_REQUIREMENT) / 5000.)
	mat.set_shader_parameter("cloud_alpha", terraform_properties.pressure / 100000)
	if terraform_properties.pressure > 0 and terraform_properties.pressure < 500000:
		atmosphere.show()
		atmosphere.mesh.material.set_shader_parameter("atmosphere_strength", terraform_properties.pressure / 100000)
		atmosphere.mesh.material.set_shader_parameter("atmosphere_color", OXYGEN_GRADIENT.sample(terraform_properties.oxygen / 420000))
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
	mat.set_shader_parameter("cities", cities_light)
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
	mat.set_shader_parameter("full_cloud_noise_map", new_noise_tex)
	mat.set_shader_parameter("color_band1", planet_properties.representative_color)
	mat.set_shader_parameter("color_band2", planet_properties.representative_color * 0.7)


func _on_planet_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not in_creating_city and event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var price := 1000000 * (Game.planet.cities.size() + 1)
		if price > Game.terras:
			Game.in_game_ui.not_enough_money.notice(price, "build", "city")
			return
		var lat_lon := Game.get_latitude_longitude(to_local(event_position))
		var elevation := planet_properties.get_elevation(lat_lon)
		in_creating_city = true
		var city_name := await Game.in_game_ui.create_new_city_popup.request_create_new_city_name(Vector3(lat_lon.x, lat_lon.y, elevation.r), price)
		in_creating_city = false
		var new_city := City.new(self, true)
		new_city.name = city_name
		new_city.geoposition = Vector3(lat_lon.x, lat_lon.y, elevation.r)
		cities.append(new_city)
		update_cities_light()
