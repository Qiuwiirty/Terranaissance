extends Resource
class_name CityProperties
var population : float = 0. #Why not in int? So population can be increased by mutiplication which eventually accumulate. also it will be rounded when showed
var habitations : int = 0

func add(other: CityProperties) -> void:
	population += other.population
	habitations += other.habitations

func subtract(other: CityProperties) -> void:
	population -= other.population
	habitations -= other.habitations
