extends Resource
class_name Facility
## (NOTICE: When freed or deleted, call delete() first!)
## A unit that provides modification to planet or city
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
static var facilities_tech : Dictionary[StringName, String] = {
	#Heat
	&"Cooling Plant": "-- 4 heat",
	&"Aerostat Platform": "-- 40 heat,++ 3000 revenue",
	&"Solar Shade": "-- 100 heat,-- 20 biomass,-- 5000 revenue",
	&"Heating Cluster": "++ 4 heat",
	&"Borehole": "++ 60 heat, ++ 10 pressure",
	&"Orbital Mirror": "++ 120 heat, -- 10 water, -- 20 biomass",
	#Pressure
	&"Sequestration Plant": "- 4 pressure",
	&"Biofixture Lab": "- 10"
}
var planet: Planet
var city: City
var category := Category.MISC

var planet_terraform_modifier_per_tick: TerraformProperties
var planet_terraform_modifier: TerraformProperties  # Only modify when initialized, unlike per tick. Usually for habitations and permanent things

var city_properties_modifier_per_tick: CityProperties
var city_properties_modifier: CityProperties
## Modifier definition is a human readable format in string for setting the property modifiers. Format is: "property operation value, property ..." (Operation: (+ add, - subtract. ++ add per tick, -- subtract per tick))
func _init(planet_: Planet, city_: City, modifier_definition : String = "") -> void:
	planet = planet_
	city = city_
	if modifier_definition != "":
		construct_and_set(modifier_definition)
	planet.terraform_modifier_per_tick.add(planet_terraform_modifier_per_tick)
	planet.terraform_properties.add(planet_terraform_modifier)
	city.city_properties_modifier_per_tick.add(city_properties_modifier_per_tick)
	city.properties.add(city_properties_modifier)

func set_planet_modifier_per_tick(mod_per_tick: TerraformProperties) -> void:
	planet.terraform_modifier_per_tick.subtract(planet_terraform_modifier_per_tick)
	planet_terraform_modifier_per_tick = mod_per_tick
	planet.terraform_modifier_per_tick.add(planet_terraform_modifier_per_tick)

func set_planet_modifier(mod: TerraformProperties) -> void:
	planet.terraform_properties.subtract(planet_terraform_modifier)
	planet_terraform_modifier = mod
	planet.terraform_properties.add(planet_terraform_modifier)

func set_city_modifier_per_tick(mod_per_tick: CityProperties) -> void:
	city.city_properties_modifier_per_tick.subtract(city_properties_modifier_per_tick)
	city_properties_modifier_per_tick = mod_per_tick
	city.city_properties_modifier_per_tick.add(city_properties_modifier_per_tick)

func set_city_modifier(mod: CityProperties) -> void:
	city.properties.subtract(city_properties_modifier)
	city_properties_modifier = mod
	city.properties.add(city_properties_modifier)

func delete() -> void:
	planet.terraform_modifier_per_tick.subtract(planet_terraform_modifier_per_tick)
	planet.terraform_properties.subtract(planet_terraform_modifier)
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
	}
	var sections := text.split(",")
	for section in sections:
		var sub_sections := section.split(" ")
		var operation_str := sub_sections[FacilityFormat.OPERATION]
		var value_str := sub_sections[FacilityFormat.VALUE]
		var property_str := sub_sections[FacilityFormat.PROPERTY]
		if ALIAS.has(property_str): property_str = ALIAS[property_str]
		match operation_str:
			"+", "-":
				if property_str in TerraformProperties:
					if operation_str == "+":
						planet_terraform_modifier.set(property_str, float(value_str))
					else:
						planet_terraform_modifier.set(property_str, -float(value_str))
				elif property_str in CityProperties:
					if operation_str == "+":
						city_properties_modifier.set(property_str, float(value_str))
					else:
						city_properties_modifier.set(property_str, -float(value_str))
			"++", "--":
				if property_str in TerraformProperties:
					if operation_str == "++":
						planet_terraform_modifier_per_tick.set(property_str, float(value_str))
					else:
						planet_terraform_modifier_per_tick.set(property_str, -float(value_str))
				elif property_str in CityProperties:
					if operation_str == "++":
						planet_terraform_modifier_per_tick.set(property_str, float(value_str))
					else:
						planet_terraform_modifier_per_tick.set(property_str, -float(value_str))
