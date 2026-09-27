@icon("uid://gb458n7jp5bh")
extends Resource
class_name Gas
enum UniqueProperty {
	NONE,
	HYPER_FLAMMABLE, ##Flammable when any oxidizer present is present 
	OXIDIZER, ##Make things able to burn (O2)
	ACIDIFICATION, ##Basically, just acid (obviously)
	ANTI_FREEZE, ##Make ocean not freeze even if it's supposed to
}
@export var name: String = "Unnamed"
##Chemical symbols like O₂
@export var symbol: String = "Unnamed"
##Uses log function so nonlinear. +Temp(kelvin) = greenhouse * ln(1+concentration ppm) * (planet pressure / 100 000 pa). Then * 1000 to get mk
@export var greenhouse: float = 0.0
##Representative color, or distinct color
@export var color: Color
##Each of ppm of this gas, add the toxicity with the value
##For example if it has 1000 ppm toxicity, 20 ppm of those will have 20_000 ppm toxicity and will add up with other toxic gas aswell
@export var toxicity_per_ppm: float = 0.
@export var unique_property: UniqueProperty = UniqueProperty.NONE
