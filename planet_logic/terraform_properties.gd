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
var pressure := 0.0 #in pa
var oxygen := 0.0 #in ppm
var water := 0.0 #in cm
var biomass := 0.0 #in mt
var revenue := 0.0

func closeness(value: float, ideal: float) -> float:
	return clampf(1.0 - abs(value - ideal) / ideal, 0.0, 1.0)
func add(other: TerraformProperties) -> void:
	temperature += other.temperature
	pressure += other.pressure
	oxygen += other.oxygen
	water += other.water
	biomass += other.biomass
	revenue += other.revenue

func subtract(other: TerraformProperties) -> void:
	temperature -= other.temperature
	pressure -= other.pressure
	oxygen -= other.oxygen
	water -= other.water
	biomass -= other.biomass
	revenue -= other.revenue

func mutiply(other: TerraformProperties) -> void:
	temperature *= other.temperature
	pressure *= other.pressure
	oxygen *= other.oxygen
	water *= other.water
	biomass *= other.biomass
	revenue *= other.revenue
	
func mutiply_float(value: float) -> void:
	temperature *= value
	pressure *= value
	oxygen *= value
	water *= value
	biomass *= value
	revenue *= value

func check_habitability_classification(value: float) -> TerraformClassification:
	return TerraformClassification.BARREN
