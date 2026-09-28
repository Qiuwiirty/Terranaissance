extends AtmosphereComposition
class_name SimpleAtmosphereComposition
const OXYGEN_GRADIENT : Gradient = preload("uid://w3mrnkqo8pl2")
@export var oxygen_gas_data : GasData = GasData.new(load("uid://dpncodof1o6e8"), 0.0)
#Initially, might wanna added co2, inert gas and toxic gas. Then realizing it's becoming too complex (which is kinda counterintuitive)
const HABITABILITY_RANGES : Dictionary[TerraformProperties.TerraformClassification, Dictionary] = {
	TerraformProperties.TerraformClassification.PERFECT: {&"Oxygen": Vector2(190_000, 220_000)},
	TerraformProperties.TerraformClassification.HABITABLE: {&"Oxygen": Vector2(175_000, 275_000)},
	TerraformProperties.TerraformClassification.PLANT_LIFE: {&"Oxygen": Vector2(150_000, 300_000)},
	TerraformProperties.TerraformClassification.MICROBE_LIFE: {&"Oxygen": Vector2(0, 400_000)}
}
func get_atmosphere_color() -> Color:
	return OXYGEN_GRADIENT.sample(oxygen_gas_data.ppm / 420000)
func get_habitability() -> TerraformProperties.TerraformClassification:
	for classification in HABITABILITY_RANGES:
		var o2_range := HABITABILITY_RANGES[classification]
		if oxygen_gas_data.ppm >= o2_range.x and oxygen_gas_data.ppm <= o2_range.y:
			return classification
	return TerraformProperties.TerraformClassification.BARREN
func add(other: SimpleAtmosphereComposition) -> void:
	oxygen_gas_data.ppm += other.oxygen_gas_data.ppm
	
func subtract(other: SimpleAtmosphereComposition) -> void:
	oxygen_gas_data.ppm -= other.oxygen_gas_data.ppm
	
func mutiply(other: AtmosphereComposition) -> void:
	oxygen_gas_data.ppm *= other.oxygen_gas_data.ppm
	
func mutiply_float(value: float) -> void:
	oxygen_gas_data.ppm *= value

func get_symbols() -> Dictionary[StringName, String]:
	return {&"Oxygen": "O₂"}
	
func get_elements() -> Dictionary[StringName, GasData]:
	return {&"Oxygen": oxygen_gas_data}
	
func get_custom_colors() -> Array[Color]:
	return [Color.AQUAMARINE, Color.DIM_GRAY]
	
func get_habitability_ranges() -> Dictionary[TerraformProperties.TerraformClassification, Dictionary]:
	return HABITABILITY_RANGES
	
