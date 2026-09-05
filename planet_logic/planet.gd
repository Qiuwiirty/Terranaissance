extends MeshInstance3D
class_name Planet
static var planets_template: Dictionary[String, PlanetProperties]
@onready var tick_timer : Timer = $TickTimer

var planet_properties : PlanetProperties
var terraform_properties : TerraformProperties
var terraform_modifier_per_tick : TerraformProperties
var cities : Array[City]
var outposts : Array

@onready var mat: Material = mesh.material
static func _static_init() -> void:
	var mars := PlanetProperties.new()
	mars.axial_tilt = 25.19
	mars.orbital_tilt = 1.85
	mars.max_elevation = 2150000
	mars.map = load("uid://bsas3wag8j7cs")
	mars.elevation_map = load("uid://c5v61glibq5lm")
	planets_template["mars"] = mars
	
func _ready() -> void:
	planet_properties = planets_template["mars"]
	terraform_properties = TerraformProperties.new()
	update_planet_properties()
	prepare_gas_giant_appearance()
func _on_update_tick() -> void:
	terraform_properties.add(terraform_modifier_per_tick)
func update_planet_properties() -> void:
	mat.set_shader_parameter("map", planet_properties.map)
	mat.set_shader_parameter("elevation_map", planet_properties.elevation_map)
	update_appearance_sea_level()
	planet_properties.update_representative_color()
func update_appearance_sea_level() -> void:
	mesh.material.set_shader_parameter("normalized_sea_level", terraform_properties.water / planet_properties.max_elevation)
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
