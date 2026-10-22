class_name RandomPlanetGenerator
extends Node3D
@onready var planet_render: PlanetRender = $PlanetRender
@onready var sun: Sun = $Sun
var planet_properties: PlanetProperties = PlanetProperties.new()
var terraform_properties: TerraformProperties = TerraformProperties.new()
const FREQUENCY_CURVE : Curve = preload("uid://chkym846di8e3")
func _ready() -> void:
	%Generate.button_up.connect(generate)
	planet_render.planet_properties = planet_properties
	planet_render.terraform_properties = terraform_properties
	planet_render.sun = sun
func generate() -> void:
	var seed_ = randi()
	generate_properties(seed_)
	planet_render.planet_properties.map = generate_map(seed_)
	await get_tree().process_frame #Noisetexture2d need some time to generate
	planet_render.init_planet_properties()
func generate_properties(seed_: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	#The basic stuff
	planet_properties.name = "Planet: " + str(seed_) #placeholder
	planet_properties.radius = pow(1.0 - randf(), 2.0) * 31_300 + 1500 #31_300 from 32800-1500
	planet_properties.max_elevation = rng.randf_range(1_000_000 ,10_000_000)
	planet_properties.habitable_water_level = rng.randf_range(0.3, 0.7)
	planet_properties.axial_tilt = pow(1.0 - randf(), 3.0) * 360
	planet_properties.orbital_tilt = pow(1.0 - randf(), 3.0) * 360
func generate_map(seed_: int) -> NoiseTexture2D:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	var noise_tex := NoiseTexture2D.new()
	noise_tex.width = 2048
	noise_tex.height = 1024
	noise_tex.seamless = true
	var new_color_ramp := Gradient.new()
	var rng_color : Color = Color(rng.randf(), rng.randf(), rng.randf())
	for i in rng.randi_range(2,3):
		new_color_ramp.add_point(
				rng.randf(), 
				Color(
				rng_color.r + rng.randf_range(-0.5,0.5), 
				rng_color.g + rng.randf_range(-0.5,0.5), 
				rng_color.b + rng.randf_range(-0.5,0.5))
				)
	noise_tex.color_ramp = new_color_ramp
	var noise := FastNoiseLite.new()
	noise.frequency = planet_render.planet_properties.radius * 5e-06
	noise.noise_type = rng.randi_range(0, 5) as FastNoiseLite.NoiseType
	noise.seed = seed_
	noise.fractal_type = rng.randi_range(0, 4) as FastNoiseLite.FractalType
	noise.domain_warp_enabled = rng.randi_range(0, 1)
	if noise.domain_warp_enabled:
		noise.domain_warp_fractal_lacunarity = 0. #It make its look grainy and ugly. don't wanna that
		noise.domain_warp_type = rng.randi_range(0, 2) as FastNoiseLite.DomainWarpType
		noise.domain_warp_fractal_type = rng.randi_range(0, 2) as FastNoiseLite.DomainWarpFractalType
	noise_tex.noise = noise
	return noise_tex
	
