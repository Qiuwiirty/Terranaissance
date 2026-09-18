extends Resource
class_name PlanetSave
## Basically a save data. This still important at runtime, because game will check on the save file on what terra mode (simple/complex) are you on.
enum TerraMode {
	SIMPLE,
	COMPLEX, #Comp It contains terras, and other stuff which unique to that savelex atmospheric composition (soon to be added ig)
}
@export var planet_properties : PlanetProperties
@export var terraform_properties : TerraformProperties = TerraformProperties.new()

@export var cities : Array[City]

@export var terra_mode: TerraMode = TerraMode.SIMPLE

func serialize(planet: Planet) -> void:
	pass
