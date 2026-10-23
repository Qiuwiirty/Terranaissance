class_name RandomPlanetGenerator
extends Node3D
const RANDOM_PLANET_RESOURCES_CURVE: Curve = preload("uid://chik7ps4mjtid")
@onready var planet_render: PlanetRender = $PlanetRender
@onready var sun: Sun = $SunContainer/Sun
var planet_properties: PlanetProperties = PlanetProperties.new()
var terraform_properties: TerraformProperties = TerraformProperties.new()
func _ready() -> void:
	%Generate.button_up.connect(generate)
	planet_render.planet_properties = planet_properties
	planet_render.terraform_properties = planet_properties.starting_terraform_properties
	planet_render.sun = sun
func generate() -> void:
	var seed_ = randi()
	generate_properties(seed_)
	generate_sun(seed_)
	planet_render.planet_properties.map = generate_map(seed_)
	await get_tree().process_frame #Noisetexture2d need some time to generate
	planet_properties.update_representative_color() #Since the color of terrain is changed, so we need to change the representative color
	planet_render.init_planet_properties()
func generate_sun(seed_: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	var new_sun_properties := SunProperties.new()
	new_sun_properties.spectrum = rng.randf()
	new_sun_properties.light_intensity = rng.randf_range(1.0, 5.0)
	
	sun.properties = new_sun_properties
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
	planet_properties.resource_abundance = RANDOM_PLANET_RESOURCES_CURVE.sample_baked(randf())
	
	#Terraforming properties
	#Temperature
	if rng.randf() >= 0.95: #5% to be lava planet:
		planet_properties.starting_terraform_properties.temperature = rng.randf_range(1_500_000, 5_000_000)
	else:
		planet_properties.starting_terraform_properties.temperature = rng.randf_range(500, 1_499_999)
	#Water, pressure and atmosphere
	if rng.randf() >= 0.6: #40% to have pressure
		if rng.randf() >= 0.95: #5% to have high pressure
			planet_properties.starting_terraform_properties.pressure = rng.randf_range(500_000, 50_000_000)
		else:
			planet_properties.starting_terraform_properties.pressure = rng.randf_range(500, 499_000)
		if rng.randf() >= 0.7: #30% to have water
			planet_properties.starting_terraform_properties.water = rng.randf_range(0, planet_properties.max_elevation)
		planet_properties.starting_terraform_properties.atmosphere_composition = generate_random_atmosphere(seed_)
func generate_random_atmosphere(seed_: int) -> ComplexAtmosphereComposition:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	var complex_atmosphere_composition := ComplexAtmosphereComposition.new()
	
	if Game.name_to_gas.is_empty():
		push_warning("Game.name_to_gas is empty :3")
		return complex_atmosphere_composition
		
	var all_gas_keys: Array = Game.name_to_gas.keys()
	all_gas_keys.shuffle()
	
	#2 to 5 gases in atmosphere
	var num_gases: int = rng.randi_range(2, mini(5, all_gas_keys.size()))
	var selected_keys: Array = all_gas_keys.slice(0, num_gases)
	
	var raw_weights: Array[float] = []
	var total_weight: float = 0.0
	
	for i in range(selected_keys.size()):
		var weight = rng.randf_range(1.0, 100.0)
		raw_weights.append(weight)
		total_weight += weight
	for i in range(selected_keys.size()):
		var gas_name: StringName = selected_keys[i]
		var gas_resource: Gas = Game.name_to_gas[gas_name]
		
		#normalize weight ratio and scale to target total PPM
		var calculated_ppm: float = (raw_weights[i] / total_weight) * 1_000_000
		
		var gas_data = GasData.new()
		gas_data.gas = gas_resource
		gas_data.ppm = calculated_ppm
		
		complex_atmosphere_composition.add_or_insert(gas_data)
		
	return complex_atmosphere_composition
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
	
