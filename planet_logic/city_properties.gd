extends Resource
class_name CityProperties
var population := 0.
var habitations := 0.

func add(other: CityProperties) -> void:
	population += other.population
	habitations += other.habitations

func subtract(other: CityProperties) -> void:
	population -= other.population
	habitations -= other.habitations
