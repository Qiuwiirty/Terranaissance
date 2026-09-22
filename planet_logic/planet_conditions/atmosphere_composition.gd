@abstract class_name AtmosphereComposition
extends Resource
@abstract func get_habitability() -> TerraformProperties.TerraformClassification
@abstract func get_atmosphere_color() -> Color

#These are not statically typed, so the inherited class can use another type freely
@abstract func add(other) -> void
@abstract func subtract(other) -> void
@abstract func mutiply(other) -> void
@abstract func mutiply_float(value: float) -> void
#@abstract func divide() -> void

#region Statistic purposes
@abstract func get_custom_colors() -> Array[Color]
@abstract func get_elements() -> Dictionary[String, float]
