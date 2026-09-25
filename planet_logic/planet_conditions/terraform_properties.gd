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
var temperature := 0.0 #in mk
var pressure : float = 0 #pa
var atmosphere_composition: AtmosphereComposition = SimpleAtmosphereComposition.new()
var water := 0.0 #in cm
var biomass := 0.0 #in mt
var revenue := 0.0

func add(other: TerraformProperties) -> void:
	temperature += other.temperature
	atmosphere_composition.add(other.atmosphere_composition)
	water += other.water
	biomass += other.biomass
	revenue += other.revenue

func subtract(other: TerraformProperties) -> void:
	temperature -= other.temperature
	atmosphere_composition.subtract(other.atmosphere_composition)
	water -= other.water
	biomass -= other.biomass
	revenue -= other.revenue

func mutiply(other: TerraformProperties) -> void:
	temperature *= other.temperature
	atmosphere_composition.mutiply(other.atmosphere_composition)
	water *= other.water
	biomass *= other.biomass
	revenue *= other.revenue
	
func mutiply_float(value: float) -> void:
	temperature *= value
	atmosphere_composition.mutiply_float(value)
	water *= value
	biomass *= value
	revenue *= value
const HABITABILITY_RANGES : Dictionary[TerraformClassification, Dictionary] = {
	TerraformClassification.PERFECT: {
		"temperature": Vector2(275_000.0, 305_000.0),
		"pressure": Vector2(90_000.0, 110_000.0),
		"water": 0.90,
		"biomass": 1.0 #Biomass use a ratio
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
