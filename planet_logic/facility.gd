extends Resource
class_name Facility
## (NOTICE: When freed or deleted, call delete() first!)
## A unit that provides modification to city.planet or city
enum Category {
	TEMPERATURE, #0
	PRESSURE, #1
	OXYGEN, #2
	WATER, #3
	BIOMASS, #4
	REVENUE, #5
	POPULATION, #6
	HABITATIONS, #7
	MISC #8
}
#The icon are mostly from noto font emoji
const CATEGORY_TO_TEXTURE: Dictionary[Facility.Category, Texture2D] = {
	Category.TEMPERATURE: preload("uid://ds3t4gw3sh4yw"),
	Category.PRESSURE: preload("uid://b2kpn1wp7ohdm"),
	Category.OXYGEN: preload("uid://bi8pbh57x84pu"),
	Category.WATER: preload("uid://bbeisdub76ybi"),
	Category.BIOMASS: preload("uid://drlvtre1ictnp"),
	Category.REVENUE: preload("uid://css0gk1xlxis0"),
	Category.POPULATION: preload("uid://dak1q80vgqll8"),
	Category.HABITATIONS: preload("uid://dak1q80vgqll8"), #use the same as population
	Category.MISC: preload("uid://da5o8jj66i7p")
}
#the name is still placeholder, maybe change it later?
static var facilities_tech : Dictionary[StringName, String] = {
	# Heat
	&"Cooler Alpha": "n=Cooler Alpha,c=0.-- 4 heat",
	&"Cooler Beta": "n=Cooler Beta,c=0.-- 40 heat,++ 3000 revenue",
	&"Cooler Gamma": "n=Cooler Gamma,c=0.-- 100 heat,-- 20 biomass,-- 5000 revenue",
	&"Heating Alpha": "n=Heating Alpha,c=0.++ 4 heat",
	&"Heating Beta": "n=Heating Beta,c=0.++ 60 heat,++ 10 pressure",
	&"Heating Gamma": "n=Heating Gamma,c=0.++ 120 heat,-- 10 water,-- 20 biomass",

	# Pressure
	&"Depressurization Alpha": "n=Depressurization Alpha,c=1.-- 4 pressure",
	&"Depressurization Beta": "n=Depressurization Beta,c=1.-- 40 pressure,++ 9 biomass",
	&"Depressurization Gamma": "n=Depressurization Gamma,c=1.-- 100 pressure,++ 20 water,++ 10 heat",
	&"Pressurization Alpha": "n=Pressurization Alpha,c=1.++ 4 pressure",
	&"Pressurization Beta": "n=Pressurization Beta,c=1.++ 60 pressure,++ 10 oxygen",
	&"Pressurization Gamma": "n=Pressurization Gamma,c=1.++ 100 pressure,++ 20 oxygen,++ 2000 revenue",

	# Oxygen
	&"Oxygenation Alpha": "n=Oxygenation Alpha,c=2.-- 4 oxygen",
	&"Oxygenation Beta": "n=Oxygenation Beta,c=2.-- 40 oxygen,++ 10 pressure",
	&"Oxygenation Gamma": "n=Oxygenation Gamma,c=2.-- 80 oxygen,++ 20 water",
	&"Deoxygenation Alpha": "n=Deoxygenation Alpha,c=2.++ 4 oxygen",
	&"Deoxygenation Beta": "n=Deoxygenation Beta,c=2.++ 60 oxygen,-- 10 pressure",
	&"Deoxygenation Gamma": "n=Deoxygenation Gamma,c=2.++ 120 oxygen,++ 17 biomass,-- 10 pressure",

	# Water
	&"Water Depletion Alpha": "n=Water Depletion Alpha,c=3.-- 4 water",
	&"Water Depletion Beta": "n=Water Depletion Beta,c=3.-- 40 water,++ 10 oxygen",
	&"Water Depletion Gamma": "n=Water Depletion Gamma,c=3.-- 120 water,-- 10 pressure,++ 3000 revenue",
	&"Flooding Alpha": "n=Flooding Alpha,c=3.++ 4 water",
	&"Flooding Beta": "n=Flooding Beta,c=3.++ 40 water,++ 10 pressure",
	&"Flooding Gamma": "n=Flooding Gamma,c=3.++ 120 water,-- 9 biomass,++ 8000 revenue",

	# Biomass
	&"Aquatic Alpha": "n=Aquatic Alpha,c=4.++ 8 biomass,-- 4 water",
	&"Aquatic Beta": "n=Aquatic Beta,c=4.++ 30 biomass,++ 30 oxygen",
	&"Aquatic Gamma": "n=Aquatic Gamma,c=4.++ 100 biomass,-- 10 water,++ 3000 revenue",
	&"Forestation Alpha": "n=Forestation Alpha,c=4.++ 4 biomass",
	&"Forestation Beta": "n=Forestation Beta,c=4.++ 20 biomass,++ 8 oxygen",
	&"Forestation Gamma": "n=Forestation Gamma,c=4.++ 80 biomass,++ 16 oxygen",

	# Habitation
	&"Habitation Alpha": "n=Habitation Alpha,c=7.+ 100 habitat",
	&"Habitation Beta": "n=Habitation Beta,c=7.+ 750 habitat,+ 4 pressure",
	&"Habitation Gamma": "n=Habitation Gamma,c=7.+ 3000 habitat,++ 1 habitat,-- 2 biomass",
	&"Population Alpha": "n=Population Alpha,c=6.++ 4 population",
	&"Population Beta": "n=Population Beta,c=6.++ 30 population,- 4 oxygen",
	&"Population Gamma": "n=Population Gamma,c=6.++ 120 population,+ 2000 revenue"
}
var city: City
var name: StringName = &"Unnamed"
var category := Category.MISC
var cached_facform := ""
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

enum FacilityPart {
	METADATA,
	MODIFIERS
}
enum FacilityFormat {
	OPERATION, #How is it operated (+ add, - subtract. ++ add per tick, -- subtract per tick)
	VALUE, #Value to add/decreased
	PROPERTY, #Property to edit (e.g. heat)
} # example : "-- 1 heat ,+ 5 habitations"

## Construct property modifiers in a human readable format in string (I called it facform lol). Format is: "property operation value, property ..." (Operation: (+ add, - subtract. ++ add per tick, -- subtract per tick))
##
## It's constructed in 2 part. "metadata. modifiers" like for example "name=Cooler Alpha, category=TEMPERATURE.-- 4 heat, + 2 habitations"
## For enum, you must input int and not string like PRESSURE (instead 1)
func construct_and_set(text: String) -> void:
	const ALIAS : Dictionary[String, String] = { #A format may use alias and need to convert
		"heat": "temperature",
		"o2": "oxygen",
		"habitat": "habitations",
		"n": "name",
		"c": "category"
	}
	var parts := text.split(".", true)
	
	var meta_sections := parts[FacilityPart.METADATA].split(",")
	for meta_section in meta_sections:
		meta_section = meta_section.strip_edges()
		var sub_meta_section := meta_section.split("=")
		var name_mod := sub_meta_section[0] #0 will always be the name that be modified
		if ALIAS.has(name_mod): name_mod = ALIAS[name_mod]
		var value_mod := sub_meta_section[1]
		if name_mod in self:
			set(name_mod, value_mod)
		else:
			push_error("Unrecgonized metadata name modifier!: ", name_mod)
	var sections := parts[FacilityPart.MODIFIERS].split(",")
	for section in sections:
		section = section.strip_edges()
		cached_facform = section
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
func get_facform(with_metadata: bool = false) -> String:
	if with_metadata:
		return "name=%s, category=%s.%s" % [name, category, cached_facform]
	return cached_facform
#this isn't necessary because.. just cache the modifiers. It does come in handy when don't use that construct and set 
#func _deconstruct_modifier(modifier: Object, add_operation: String, sub_operation: String) -> Array[String]:
	#var result: Array[String] = []
	#
	#for property in modifier.get_property_list():
		#var property_name: String = property.name
		##ignore godot builtin objects thing
		#if property_name.begins_with("_"):
			#continue
			#
		#var value : Variant = modifier.get(property_name)
		#
		#if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
			#continue
			#
		#if is_zero_approx(float(value)):
			#continue
			#
		#var operation := add_operation if value > 0 else sub_operation
		#var absolute_value := absf(float(value))
		#
		#result.append("%s %s %s" % [operation, absolute_value, property_name ])
		#
	#return result
	#
#func get_facform(with_metadata: bool = false) -> String:
	#var modifiers: Array[String] = []
	#modifiers.append_array(_deconstruct_modifier(planet_terraform_modifier, "+", "-"))
	#modifiers.append_array(_deconstruct_modifier(city_properties_modifier, "+", "-"))
	#
	##per tick use double (to indicate that happened every tick obviously)
	#modifiers.append_array(_deconstruct_modifier(planet_terraform_modifier_per_tick, "++", "--"))
	#modifiers.append_array(_deconstruct_modifier(city_properties_modifier_per_tick, "++", "--"))
	#
	#var result := ""
	#
	#if with_metadata:
		#result += "name=%s, category=%s." % [name, category]
		#
	#result += ", ".join(modifiers)
	#
	#return result
