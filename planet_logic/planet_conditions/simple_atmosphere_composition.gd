extends AtmosphereComposition
class_name SimpleAtmosphereComposition
const OXYGEN_GRADIENT : Gradient= preload("uid://w3mrnkqo8pl2")
var oxygen : float = 0 #ppm
#Initially, might wanna added co2, inert gas and toxic gas. Then realizing it's becoming too complex (which is kinda counterintuitive)
func get_atmosphere_color() -> Color:
	return OXYGEN_GRADIENT.sample(oxygen / 420000)
func get_habitability() -> TerraformProperties.TerraformClassification:
	if oxygen >= 190000 and oxygen <= 220000:
		return TerraformProperties.TerraformClassification.PERFECT
		
	if oxygen >= 175000 and oxygen <= 275000:
		return TerraformProperties.TerraformClassification.HABITABLE
		
	if oxygen >= 150000 and oxygen <= 300000:
		return TerraformProperties.TerraformClassification.PLANT_LIFE
		
	if oxygen <= 400000:
		return TerraformProperties.TerraformClassification.MICROBE_LIFE
	
	if oxygen >= 900000:
		return TerraformProperties.TerraformClassification.HELLISH
	return TerraformProperties.TerraformClassification.BARREN
func add(other: SimpleAtmosphereComposition) -> void:
	oxygen += other.oxygen
	
func subtract(other: SimpleAtmosphereComposition) -> void:
	oxygen -= other.oxygen
	
func mutiply(other: AtmosphereComposition) -> void:
	oxygen *= other.oxygen
	
func mutiply_float(value: float) -> void:
	oxygen *= value
	
func get_elements() -> Dictionary[String, float]:
	return {"Oxygen": oxygen, "Other gases": 1_000_000 - oxygen}

func get_custom_colors() -> Array[Color]:
	return [Color.AQUAMARINE, Color.DIM_GRAY]
