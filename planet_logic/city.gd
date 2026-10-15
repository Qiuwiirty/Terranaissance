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

var terraform_properties_modifier_per_tick: TerraformProperties

func run() -> void:
	properties.population *= 1.00021 + randf_range(-0.00021, 0.00021)
	properties.population = minf(properties.population, properties.habitations)
func _init(planet_: Planet, create_habitat := true) -> void:
	planet = planet_
	planet.tick_timer.timeout.connect(run)
	if create_habitat:
		var new_habitat := Facility.new(self, load("uid://crnxp3lx3nmvl").get_modifiers())
		properties.population += new_habitat.city_modifier.habitations
func delete_facility(what: Facility) -> void:
	assert(facilities.has(what))
	what.delete()
	facilities.erase(what)
	properties.population = minf(properties.population, properties.habitations)
func request_recalculation() -> void:
	var new_properties_modifier_per_tick := CityProperties.new()
	var new_terraform_properties_modifier_per_tick := TerraformProperties.new()

	var new_habitations := 0 #Why no new properties? Because.. you can't exactly modify population one time thing.
	for facility in facilities:
		new_properties_modifier_per_tick.add(facility.city_modifier_per_tick)
		new_terraform_properties_modifier_per_tick.add(facility.terraform_modifier_per_tick)
		new_habitations += facility.city_modifier.habitations
		
		#any gas
		if !is_zero_approx(facility.any_gas_modifier):
			new_terraform_properties_modifier_per_tick.atmosphere_composition.add_or_insert(GasData.new(facility.any_gas, facility.any_gas_modifier))
	terraform_properties_modifier_per_tick = new_terraform_properties_modifier_per_tick
	properties_modifier_per_tick = new_properties_modifier_per_tick
	properties.habitations = new_habitations
	planet.request_recalculation()

func add_building_facility(facility_data: FacilityData) -> WaitTask:
	var new_wait_task := WaitTask.new(facility_data.build_time)
	Game.planet.append_wait_task(new_wait_task)
	new_wait_task.completed.connect(func() -> void: Facility.new(self, facility_data.get_modifiers()))
	return new_wait_task
func add_upgrading_facility(facility: Facility) -> WaitTask:
	var new_wait_task := WaitTask.new(int(facility.build_time * facility.max_level / 4)) #ADJ
	Game.planet.append_wait_task(new_wait_task)
	new_wait_task.completed.connect(_upgrade_facility.bind(facility))
	return new_wait_task
func _upgrade_facility(facility: Facility) -> void:
	facility.max_level += 1
	facility.level = facility.max_level
