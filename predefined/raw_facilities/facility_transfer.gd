extends RefCounted
class_name FacilityTransfer
## This is only for data transfer specifically for facility (NON RESEARCH..
var name : StringName
var category : Facility.Category
var description : StringName
var terraform_modifier_per_tick: TerraformProperties = TerraformProperties.new()

var any_gas_modifier: float = 0.0 #Modify any atmopshere modifier that have been selected
var any_gas: Gas

var city_modifier_per_tick: CityProperties = CityProperties.new()
var city_modifier: CityProperties = CityProperties.new()

var build_time: float = 0.0
