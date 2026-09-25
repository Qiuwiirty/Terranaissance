extends Resource
class_name PlanetSave
## Basically a save data. 

#Note that PlanetState is now used when wanting to access something constantly

#region Things that planet owns but not PlanetState
@export var planet_properties : PlanetProperties
@export var terraform_properties : TerraformProperties = TerraformProperties.new()
@export var cities : Array[City]

@export var planet_state: PlanetState
func serialize(planet: Planet) -> void:
	pass
