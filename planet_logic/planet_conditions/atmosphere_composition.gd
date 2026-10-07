@abstract class_name AtmosphereComposition
extends Resource

@abstract func get_habitability() -> TerraformProperties.TerraformClassification
@abstract func get_atmosphere_color() -> Color
@abstract func add_or_insert(gas_data: GasData) -> void

#These are not statically typed, so the inherited class can use another type freely
@abstract func add(other) -> void
@abstract func subtract(other) -> void
@abstract func mutiply(other) -> void
@abstract func mutiply_float(value: float) -> void
#@abstract func divide() -> void

#region Statistic purposes
@abstract func get_custom_colors() -> Array[Color] #Used for statistics so no need to be dictionary
@abstract func get_elements() -> Dictionary[StringName, GasData]
@abstract func get_habitability_ranges() -> Dictionary[TerraformProperties.TerraformClassification, Dictionary]

static func dict_gas_data_into_ppm(dict: Dictionary[StringName, GasData]) -> Dictionary[StringName, float]:
	var name_to_ppm : Dictionary[StringName, float]
	for key in dict:
		name_to_ppm[key] = dict[key].ppm
	return name_to_ppm
