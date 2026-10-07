extends Resource
class_name TerraformProperties
enum TerraformClassification {
	HELLISH, #when 200% away from the habitable stat (which is very far away) (not implemented yet)
	BARREN, #nothing can survive
	MICROBE_LIFE,
	PLANT_LIFE,
	HABITABLE,
	PERFECT,
}
var habitability_percentage: float:
	get:
		return 0.
var _temperature := 0.0
var greenhouse_effect := 0.0 #Inferred from atmosphere composition
@export var temperature: float : #in mk
	get:
		return _temperature + greenhouse_effect
	set(value):
		_temperature = value
@export var pressure : float = 0 ##In pa
@export var atmosphere_composition: AtmosphereComposition
@export var water := 0.0 ##In cm. If used as a starting condition, this will not correspond directly to the actual sea elevation as it will be converted to ice/vapor
@export var biomass := 0.0 ##In mt (megatonnes)
@export var revenue := 0.0 ##In terras money
func add(other: TerraformProperties) -> void:
	_temperature += other._temperature
	if atmosphere_composition:
		atmosphere_composition.add(other.atmosphere_composition)
	water += other.water
	biomass += other.biomass
	revenue += other.revenue

func subtract(other: TerraformProperties) -> void:
	_temperature -= other.temperature
	if atmosphere_composition:
		atmosphere_composition.subtract(other.atmosphere_composition)
	water -= other.water
	biomass -= other.biomass
	revenue -= other.revenue

func mutiply(other: TerraformProperties) -> void:
	_temperature *= other.temperature
	if atmosphere_composition:
		atmosphere_composition.mutiply(other.atmosphere_composition)
	water *= other.water
	biomass *= other.biomass
	revenue *= other.revenue
	
func mutiply_float(value: float) -> void:
	_temperature *= value
	if atmosphere_composition:
		atmosphere_composition.mutiply_float(value)
	water *= value
	biomass *= value
	revenue *= value
const HABITABILITY_RANGES : Dictionary[TerraformClassification, Dictionary] = {
	TerraformClassification.PERFECT: {
		"temperature": Vector2(275_000.0, 305_000.0),
		"pressure": Vector2(90_000.0, 110_000.0),
		"water": 0.90,
		"biomass": 1.0, #Biomass use a ratio
	},
	TerraformClassification.HABITABLE: {
		"temperature": Vector2(250_000.0, 320_000.0),
		"pressure": Vector2(50_000.0, 150_000.0),
		"water": 0.60,
		"biomass": 0.275
	},
	TerraformClassification.PLANT_LIFE: {
		"temperature": Vector2(210_000.0, 350_000.0),
		"pressure": Vector2(40_000.0, 1_000_000.0),
		"water": 0.40,
	},
	TerraformClassification.MICROBE_LIFE: {
		"temperature": Vector2(180_000.0, 400_000.0),
		"pressure": Vector2(5_000.0, 1_000_000.0),
		"water": 0.10,
	},
}
func get_habitability() -> TerraformClassification:
	var water_ratio := water / Game.planet.planet_properties.habitable_water_level
	for classification in [
		TerraformClassification.PERFECT,
		TerraformClassification.HABITABLE,
		TerraformClassification.PLANT_LIFE,
		TerraformClassification.MICROBE_LIFE,
	]:
		var ranges: Dictionary = HABITABILITY_RANGES[classification]
		if (
			Game.is_in_range(temperature, ranges["temperature"])
			and Game.is_in_range(pressure, ranges["pressure"])
			and water_ratio >= ranges["water"]
			and biomass / Game.planet.planet_properties.max_biomass >= ranges["biomass"]
			and atmosphere_composition.get_habitability() == classification
		):
			return classification
			
	return TerraformClassification.BARREN

##If used upon simple atmosphere composition, the values would be automatically inferred from complex
func load_from_starting_terraform_properties(other_terraform_properties: TerraformProperties) -> void:
	pressure = other_terraform_properties.pressure
	temperature = other_terraform_properties.temperature
	water = other_terraform_properties.water
	biomass = other_terraform_properties.biomass
	var other_starting_atmosphere : AtmosphereComposition = other_terraform_properties.atmosphere_composition
	if other_starting_atmosphere.get_script() == atmosphere_composition.get_script():
		atmosphere_composition = other_starting_atmosphere
		return
	var other_elements := other_starting_atmosphere.get_elements()
	if Game.planet.planet_state.terra_mode == PlanetState.TerraMode.SIMPLE:
		var new_simple_terraform_properties := SimpleAtmosphereComposition.new()
		if other_elements.has(&"Oxygen"): 
			new_simple_terraform_properties.oxygen_gas_data = other_elements[&"Oxygen"]
		atmosphere_composition = new_simple_terraform_properties
	else:
		var new_complex_terraform_properties := ComplexAtmosphereComposition.new()
		if other_elements.has(&"Oxygen"): 
			new_complex_terraform_properties.gases[&"Oxygen"] = other_elements[&"Oxygen"]
		atmosphere_composition = new_complex_terraform_properties
