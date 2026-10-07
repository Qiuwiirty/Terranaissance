@tool
extends Resource
class_name Facility
## (NOTICE: When freed or deleted, call delete() first!)
## A unit that provides modification to city.planet or city
enum Category {
	TEMPERATURE, #0
	PRESSURE, #1
	ATMOSPHERE, #2
	WATER, #3
	BIOMASS, #4
	REVENUE, #5
	POPULATION, #6
	HABITATION, #7
	MISC, #8
	UNDEFINED, #9 This is different from MISC. 
	#This only happened when the code havent explicitly change the category (which is kinda bad yknow)
}
static var alias_category : Dictionary[String, int]
#The icon are mostly from noto font emoji
const CATEGORY_TO_TEXTURE: Dictionary[Category, Texture2D] = {
	Category.TEMPERATURE: preload("uid://ds3t4gw3sh4yw"),
	Category.PRESSURE: preload("uid://b2kpn1wp7ohdm"),
	Category.ATMOSPHERE: preload("uid://gb458n7jp5bh"),
	Category.WATER: preload("uid://bbeisdub76ybi"),
	Category.BIOMASS: preload("uid://drlvtre1ictnp"),
	Category.REVENUE: preload("uid://css0gk1xlxis0"),
	Category.POPULATION: preload("uid://dak1q80vgqll8"),
	Category.HABITATION: preload("uid://dak1q80vgqll8"), #use the same as population
	Category.MISC: preload("uid://da5o8jj66i7p"),
	Category.UNDEFINED: preload("uid://b522w6sxphy5b")
}
const CATEGORY_TO_SUFFIX: Dictionary[Category, String] = {
	Category.TEMPERATURE: "mK",
	Category.PRESSURE: "Pa",
	Category.WATER: "cm",
	Category.REVENUE: "Tr",
	Category.BIOMASS: "Mt",
	Category.POPULATION: "people",
	Category.HABITATION: "unit",
	Category.MISC: "",
	Category.UNDEFINED: "Unindentified suffix"
}
var city: City
var name: StringName = &"Unnamed"
var description: StringName
##Upgrade, it's basically modifier multiplier (*1.5)
var level : int = 1
##This will impact the displayed icon in the UI too
var category := Category.UNDEFINED

var terraform_modifier_per_tick: TerraformProperties = TerraformProperties.new()
var terraform_modifier: TerraformProperties = TerraformProperties.new() # Only modify when initialized, unlike per tick. Usually for habitations and permanent things

#An atmosphere modifier that only and explicitly set certain like oxygen located in terraform properties
var city_modifier_per_tick: CityProperties = CityProperties.new()
var city_modifier: CityProperties = CityProperties.new()

var any_gas: Gas #The selected gas
var any_gas_modifier: float = 0.0 #Modify any atmopshere modifier (PER TICK)that have been selected
## Modifier definition is a human readable format in string for setting the property modifiers. Format is: "property operation value, property ..." (Operation: (+ add, - subtract. ++ add per tick, -- subtract per tick))
func _init(city_: City, facility_transfer: FacilityTransfer) -> void:
	name = facility_transfer.name
	category = facility_transfer.category
	
	description = facility_transfer.description
	terraform_modifier = facility_transfer.terraform_modifier
	terraform_modifier_per_tick = facility_transfer.terraform_modifier_per_tick
	
	city_modifier = facility_transfer.city_modifier
	city_modifier_per_tick = facility_transfer.city_modifier_per_tick
	
	any_gas_modifier = facility_transfer.any_gas_modifier
	
	city = city_
	city.planet.terraform_modifier_per_tick.add(terraform_modifier_per_tick)
	city.planet.terraform_properties.add(terraform_modifier)
	city.properties_modifier_per_tick.add(city_modifier_per_tick)
	city.properties.add(city_modifier)

func set_planet_modifier_per_tick(mod_per_tick: TerraformProperties) -> void:
	city.planet.terraform_modifier_per_tick.subtract(terraform_modifier_per_tick)
	terraform_modifier_per_tick = mod_per_tick
	city.planet.terraform_modifier_per_tick.add(terraform_modifier_per_tick)

func set_planet_modifier(mod: TerraformProperties) -> void:
	city.planet.terraform_properties.subtract(terraform_modifier)
	terraform_modifier = mod
	city.planet.terraform_properties.add(terraform_modifier)

func set_city_modifier_per_tick(mod_per_tick: CityProperties) -> void:
	city.properties_modifier_per_tick.subtract(city_modifier_per_tick)
	city_modifier_per_tick = mod_per_tick
	city.properties_modifier_per_tick.add(city_modifier_per_tick)

func set_city_modifier(mod: CityProperties) -> void:
	city.properties.subtract(city_modifier)
	city_modifier = mod
	city.properties.add(city_modifier)

func set_level(new_level: int) -> void:
	_remove_modifiers_from_objects() #remove the modifier first because don't wanna add something again
	var old_multiplier := 1.0 + (level - 1) * 0.5
	var new_multiplier := 1.0 + (new_level - 1) * 0.5
	var ratio := new_multiplier / old_multiplier
	
	terraform_modifier.mutiply_float(ratio)
	city_modifier.mutiply_float(ratio)
	terraform_modifier_per_tick.mutiply_float(ratio)
	city_modifier_per_tick.mutiply_float(ratio)
	
	level = new_level
	_apply_modifiers_to_objects() #update it
##If precedeed by _apply_modifiers_to_objects, then you essentially make it goes back (aka changes nothing). But this is useful when wanting to update (_remove, do some thing, then _apply
func _remove_modifiers_from_objects() -> void:
	city.planet.terraform_modifier_per_tick.subtract(terraform_modifier_per_tick)
	city.planet.terraform_properties.subtract(terraform_modifier)
	city.properties.subtract(city_modifier)
	city.properties_modifier_per_tick.subtract(city_modifier_per_tick)

func _apply_modifiers_to_objects() -> void:
	city.planet.terraform_modifier_per_tick.add(terraform_modifier_per_tick)
	city.planet.terraform_properties.add(terraform_modifier)
	city.properties.add(city_modifier)
	city.properties_modifier_per_tick.add(city_modifier_per_tick)

func delete() -> void:
	_remove_modifiers_from_objects()

func get_modifiers() -> FacilityTransfer:
	var new_facility_transfer := FacilityTransfer.new()
	new_facility_transfer.name = name
	new_facility_transfer.category = category
	
	new_facility_transfer.terraform_modifier = terraform_modifier
	new_facility_transfer.terraform_modifier_per_tick = terraform_modifier_per_tick
	
	new_facility_transfer.city_modifier = city_modifier
	new_facility_transfer.city_modifier_per_tick = city_modifier_per_tick
	
	new_facility_transfer.any_gas_modifier = any_gas_modifier
	return new_facility_transfer
