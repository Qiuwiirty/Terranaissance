extends Resource
class_name TerraformProperties
var temperature := 0.0
var pressure := 0.0
var oxygen := 0.0
var water := 0.0
var biomass := 0.0
var revenue := 0.0
var population := 0.0
var habitations := 0.0


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
