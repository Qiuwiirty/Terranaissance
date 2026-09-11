extends Resource
class_name City
var name := "Ciiity"
var planet: Planet
#x = latitude, y = longitude, z = elevation. 
#Z can be inferred from planet's elevation if you know x and y (however it's not needed because it's cached one time)
var geoposition: Vector3
var facilities : Array[Facility]
var events : Array
var governor : Variant

var properties : CityProperties = CityProperties.new()
var properties_modifier_per_tick : CityProperties = CityProperties.new()
func _init(planet_: Planet, create_habitat := true) -> void:
	planet = planet_
	if create_habitat:
		var new_habitat := Facility.new(self, Facility.facilities_tech[&"Habitation Alpha"])
		facilities.append(new_habitat)
		properties.population += new_habitat.city_properties_modifier.habitations
