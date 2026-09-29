@icon("uid://gb458n7jp5bh")
extends Resource
class_name GasData
##Gas with its ppm for dictionaries, like in ComplexAtmosphereComposition
@export var gas: Gas
@export var ppm: float
func _init(gas_:= Gas.new(), ppm_ := 0.0) -> void:
	gas = gas_
	ppm = ppm_
