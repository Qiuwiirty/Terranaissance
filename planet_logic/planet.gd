extends MeshInstance3D
class_name Planet

static var planets_template: Dictionary[String, PlanetProperties]
@onready var tick_timer : Timer = $TickTimer

var planet_properties : PlanetProperties
var terraform_properties : TerraformProperties
var properties_modifier_per_tick : TerraformProperties
var cities : Array[City]
var outposts : Array

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
	terraform_properties =TerraformProperties.new()
	update_planet_properties()
func update_planet_properties() -> void:
	var mat: Material = mesh.material
	mat.set_shader_parameter("map", planet_properties.map)
	mat.set_shader_parameter("elevation_map", planet_properties.elevation_map)
	update_appearance_sea_level()
func update_appearance_sea_level() -> void:
	mesh.material.set_shader_parameter("normalized_sea_level", terraform_properties.water / planet_properties.max_elevation)
