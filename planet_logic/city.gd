@icon("uid://tt10vx6tyh3k")
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

var events_log: Array[Event]
func run() -> void:
	properties.population *= 1.00021 + randf_range(-0.00021, 0.00021)
	properties.population = minf(properties.population, properties.habitations)
func _init(planet_: Planet, create_habitat := true) -> void:
	planet = planet_
	planet.tick_timer.timeout.connect(run)
	if create_habitat:
		var new_habitat := Facility.new(self, load("uid://crnxp3lx3nmvl").get_modifiers())
		facilities.append(new_habitat)
		properties.population += new_habitat.city_modifier.habitations
func delete_facility(what: Facility) -> void:
	assert(facilities.has(what))
	what.delete()
	facilities.erase(what)
	properties.population = minf(properties.population, properties.habitations)
