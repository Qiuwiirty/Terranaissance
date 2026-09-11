extends Resource
class_name Facility
## (NOTICE: When freed or deleted, call delete() first!)
## A unit that provides modification to city.planet or city
enum Category {
	TEMPERATURE,
	PRESSURE,
	OXYGEN,
	WATER,
	BIOMASS,
	REVENUE,
	POPULATION,
	HABITATIONS,
	MISC
}
#the name is still placeholder, maybe change it later?
static var facilities_tech : Dictionary[StringName, String] = {
	#Heat
	&"Cooler Alpha": "-- 4 heat",
	&"Cooler Beta": "-- 40 heat, ++ 3000 revenue",
	&"Cooler Gamma": "-- 100 heat,-- 20 biomass,-- 5000 revenue",
	&"Heating Alpha": "++ 4 heat",
	&"Heating Beta": "++ 60 heat, ++ 10 pressure",
	&"Heating Gamma": "++ 120 heat, -- 10 water, -- 20 biomass",
	#Pressure
	&"Depressurization Alpha": "-- 4 pressure",
	&"Depressurization Beta": "--  40 pressure, ++ 9 biomass",
	&"Depressurization Gamma": "--  100 pressure, ++ 20 water, ++ 10 heat",
	&"Pressurization Alpha": "++ 4 pressure",
	&"Pressurization Beta": "++ 60 pressure, ++ 10 oxygen",
	&"Pressurization Gamma": "++ 100 pressure, ++ 20 oxygen, ++ 2000 revenue",
	#Oxygen
	&"Oxygenation Alpha": "--  4 oxygen",
	&"Oxygenation Beta": "--  40 oxygen, ++ 10 pressure",
	&"Oxygenation Gamma": "--  80 oxygen, ++ 20 water",
	&"Deoxygenation Alpha": "++ 4 oxygen",
	&"Deoxygenation Beta": "++ 60 oxygen, --  10 pressure",
	&"Deoxygenation Gamma": "++ 120 oxygen, ++ 17 biomass, --  10 pressure",
	#Water
	&"Water Depletion Alpha": "--  4 water",
	&"Water Depletion Beta": "--  40 water, ++ 10 oxygen",
	&"Water Depletion Gamma": "--  120 water, --  10 pressure, ++ 3000 revenue",
	&"Flooding Alpha": "++ 4 water",
	&"Flooding Beta": "++ 40 water, ++ 10 pressure",
	&"Flooding Gamma": "++ 120 water, -- 9 biomass, ++ 8000 revenue",
	#Biomass
	&"Aquatic Alpha": "++ 8 biomass, --  4 water",
	&"Aquatic Beta": "++ 30 biomass, ++ 30 oxygen",
	&"Aquatic Gamma": "++ 100 biomass, --  10 water, ++ 3000 biomass",
	&"Forestation Alpha": "++ 4 biomass",
	&"Forestation Beta": "++ 20 biomass, ++ 8 oxygen",
	&"Forestation Gamma": "++ 80 biomass, ++ 16 oxygen",
	#Habitation
	&"Habitation Alpha": "+ 100 habitat",
	&"Habitation Beta": "+ 750 habitat, + 4 pressure",
	&"Habitation Gamma": "+ 3000 habitat, ++ 1 habitat, -- 2 biomass",
	&"Population Alpha": "++ 4 population",
	&"Population Beta": "++ 30 population, - 4 oxygen",
	&"Population Gamma": "++ 120 population, + 2000 revenue"
}
var city: City
var category := Category.MISC

var planet_terraform_modifier_per_tick: TerraformProperties = TerraformProperties.new()
var planet_terraform_modifier: TerraformProperties = TerraformProperties.new() # Only modify when initialized, unlike per tick. Usually for habitations and permanent things

var city_properties_modifier_per_tick: CityProperties = CityProperties.new()
var city_properties_modifier: CityProperties = CityProperties.new()
## Modifier definition is a human readable format in string for setting the property modifiers. Format is: "property operation value, property ..." (Operation: (+ add, - subtract. ++ add per tick, -- subtract per tick))
func _init(city_: City, modifier_definition : String = "") -> void:
	city = city_
	if modifier_definition != "":
		construct_and_set(modifier_definition)
	city.planet.terraform_modifier_per_tick.add(planet_terraform_modifier_per_tick)
	city.planet.terraform_properties.add(planet_terraform_modifier)
	city.properties_modifier_per_tick.add(city_properties_modifier_per_tick)
	city.properties.add(city_properties_modifier)

func set_planet_modifier_per_tick(mod_per_tick: TerraformProperties) -> void:
	city.planet.terraform_modifier_per_tick.subtract(planet_terraform_modifier_per_tick)
	planet_terraform_modifier_per_tick = mod_per_tick
	city.planet.terraform_modifier_per_tick.add(planet_terraform_modifier_per_tick)

func set_planet_modifier(mod: TerraformProperties) -> void:
	city.planet.terraform_properties.subtract(planet_terraform_modifier)
	planet_terraform_modifier = mod
	city.planet.terraform_properties.add(planet_terraform_modifier)

func set_city_modifier_per_tick(mod_per_tick: CityProperties) -> void:
	city.city_properties_modifier_per_tick.subtract(city_properties_modifier_per_tick)
	city_properties_modifier_per_tick = mod_per_tick
	city.city_properties_modifier_per_tick.add(city_properties_modifier_per_tick)

func set_city_modifier(mod: CityProperties) -> void:
	city.properties.subtract(city_properties_modifier)
	city_properties_modifier = mod
	city.properties.add(city_properties_modifier)

func delete() -> void:
	city.planet.terraform_modifier_per_tick.subtract(planet_terraform_modifier_per_tick)
	city.planet.terraform_properties.subtract(planet_terraform_modifier)
	city.city_properties_modifier_per_tick.subtract(city_properties_modifier_per_tick)
	city.properties.subtract(city_properties_modifier)
	free()

enum FacilityFormat {
	OPERATION, #How is it operated (+ add, - subtract. ++ add per tick, -- subtract per tick)
	VALUE, #Value to add/decreased
	PROPERTY, #Property to edit (e.g. heat)
} # example : "-- 1 heat ,+ 5 habitations"
## Construct property modifiers in a human readable format in string. Format is: "property operation value, property ..." (Operation: (+ add, - subtract. ++ add per tick, -- subtract per tick))
func construct_and_set(text: String) -> void:
	const ALIAS : Dictionary[String, String] = { #A format may use alias and need to convert
		"heat": "temperature",
		"o2": "oxygen",
		"habitat": "habitations"
	}
	var sections := text.split(",")
	for section in sections:
		section = section.strip_edges()
		var sub_sections := section.split(" ")
		var operation_str := sub_sections[FacilityFormat.OPERATION]
		var value_str := sub_sections[FacilityFormat.VALUE]
		var property_str := sub_sections[FacilityFormat.PROPERTY]
		if ALIAS.has(property_str): property_str = ALIAS[property_str]
		match operation_str:
			"+", "-":
				#it isn't matter as long the instance is Planet modifier (you can't check if var exist on class like "habitations" in PlanetProperties)
				if property_str in planet_terraform_modifier:
					if operation_str == "+":
						planet_terraform_modifier.set(property_str, float(value_str))
					else:
						planet_terraform_modifier.set(property_str, -float(value_str))
				elif property_str in city_properties_modifier:
					if operation_str == "+":
						city_properties_modifier.set(property_str, float(value_str))
					else:
						city_properties_modifier.set(property_str, -float(value_str))
				else:
					push_error("Unrecognized property that does not exist in both: ", property_str, " text: ", text)
			"++", "--":
				if property_str in planet_terraform_modifier_per_tick:
					if operation_str == "++":
						planet_terraform_modifier_per_tick.set(property_str, float(value_str))
					else:
						planet_terraform_modifier_per_tick.set(property_str, -float(value_str))
				elif property_str in city_properties_modifier_per_tick:
					if operation_str == "++":
						city_properties_modifier_per_tick.set(property_str, float(value_str))
					else:
						city_properties_modifier_per_tick.set(property_str, -float(value_str))
				else:
					push_error("Unrecognized property that does not exist in both: ", property_str, " text: ", text)
			_:
				push_error("Unrecognized operation that does not exist: ", property_str, " text: ", text)
