extends Resource
class_name PlanetState
enum TerraMode {
	SIMPLE,
	COMPLEX,
}
@export var terra_mode: TerraMode = TerraMode.SIMPLE
@export var culture: Culture = Culture.new()
@export var terras: float = 0.0
