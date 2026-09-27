extends AtmosphereComposition
class_name SimpleAtmosphereComposition
const OXYGEN_GRADIENT : Gradient= preload("uid://w3mrnkqo8pl2")
var oxygen : float = 0 #ppm
#Initially, might wanna added co2, inert gas and toxic gas. Then realizing it's becoming too complex (which is kinda counterintuitive)
const HABITABILITY_RANGES : Dictionary[TerraformProperties.TerraformClassification, Dictionary] = {
	TerraformProperties.TerraformClassification.PERFECT: {&"oxygen": Vector2(190_000, 220_000)},
	TerraformProperties.TerraformClassification.HABITABLE: {&"oxygen": Vector2(175_000, 275_000)},
	TerraformProperties.TerraformClassification.PLANT_LIFE: {&"oxygen": Vector2(150_000, 300_000)},
	TerraformProperties.TerraformClassification.MICROBE_LIFE: {&"oxygen": Vector2(0, 400_000)}
}
func get_atmosphere_color() -> Color:
	return OXYGEN_GRADIENT.sample(oxygen / 420000)
func get_habitability() -> TerraformProperties.TerraformClassification:
	for classification in HABITABILITY_RANGES:
		var o2_range := HABITABILITY_RANGES[classification]
		if oxygen >= o2_range.x and oxygen <= o2_range.y:
			return classification
	return TerraformProperties.TerraformClassification.BARREN
func add(other: SimpleAtmosphereComposition) -> void:
	oxygen += other.oxygen
	
func subtract(other: SimpleAtmosphereComposition) -> void:
	oxygen -= other.oxygen
	
func mutiply(other: AtmosphereComposition) -> void:
	oxygen *= other.oxygen
	
func mutiply_float(value: float) -> void:
	oxygen *= value

func get_symbols() -> Dictionary[StringName, String]:
	return {&"oxygen":"O₂"}

func get_elements() -> Dictionary[StringName, float]:
	return {&"oxygen": oxygen, &"other_gases": 1_000_000 - oxygen}

func get_custom_colors() -> Array[Color]:
	return [Color.AQUAMARINE, Color.DIM_GRAY]

func get_habitability_ranges() -> Dictionary[TerraformProperties.TerraformClassification, Dictionary]:
	return HABITABILITY_RANGES
