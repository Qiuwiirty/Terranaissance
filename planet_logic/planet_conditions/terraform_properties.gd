extends Resource
class_name TerraformProperties
enum TerraformClassification {
	HELLISH, #when 200% away from the habitable stat (which is very far away)
	BARREN, #nothing can survive
	MICROBE_LIFE,
	PLANT_LIFE,
	HABITABLE,
	PERFECT,
}
#Microbe life
#180k - 
var habitability_percentage: float:
	get:
		return 0.
var temperature := 0.0 #in mk
var pressure : float = 0 #pa
var atmosphere_composition: AtmosphereComposition
var water := 0.0 #in cm
var biomass := 0.0 #in mt
var revenue := 0.0

func closeness(value: float, ideal: float) -> float:
	return clampf(1.0 - abs(value - ideal) / ideal, 0.0, 1.0)
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

func check_habitability_classification(habitable_water_level: float) -> TerraformClassification:
	var water_ratio := water / habitable_water_level
	#Godot styling guide say use 2 indentation for blocks like this.. but eh it felt weird
	#Perfect
	if (
		temperature >= 275_000.0 and temperature <= 305_000.0
		and pressure >= 90.0 and pressure <= 110.0
		and atmosphere_composition.get_habitability() == TerraformClassification.PERFECT
		and water_ratio >= 0.90
	):
		return TerraformClassification.PERFECT
		
	#Habitable
	if (
		temperature >= 250_000.0 and temperature <= 320_000.0
		and pressure >= 50.0 and pressure <= 150.0
		and atmosphere_composition.get_habitability() == TerraformClassification.HABITABLE
		and water_ratio >= 0.60
	):
		return TerraformClassification.HABITABLE
		
	#Plant life
	if (
		temperature >= 210_000.0 and temperature <= 350_000.0
		and pressure >= 60.0 and pressure <= 175.0
		and atmosphere_composition.get_habitability() == TerraformClassification.PLANT_LIFE
		and water_ratio >= 0.40
	):
		return TerraformClassification.PLANT_LIFE
		
	#Microbe life
	if (
		temperature >= 180_000.0 and temperature <= 400_000.0
		and pressure >= 5.0 and pressure <= 1000.0
		and atmosphere_composition.get_habitability() == TerraformClassification.MICROBE_LIFE
		and water_ratio >= 0.10
	):
		return TerraformClassification.MICROBE_LIFE
		
	return TerraformClassification.BARREN
