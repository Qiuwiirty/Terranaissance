extends Resource
class_name FacilityData
## FacilityData simply stores the raw modifiers, description and other facilities metadata.
#Note that FacilityData (use facform) will be deprecated in favor of this
#region Thing that actually matter for facilities to function
@export var name : StringName = "Unnamed :("
@export var category := Facility.Category.UNDEFINED
@export var terraform_modifier_per_tick: TerraformProperties = TerraformProperties.new()
@export var terraform_modifier: TerraformProperties = TerraformProperties.new() # Only modify when initialized, unlike per tick. Usually for habitations and permanent things

@export var city_modifier_per_tick: CityProperties = CityProperties.new()
@export var city_modifier: CityProperties = CityProperties.new()

##User can choose any gas to increase or decrese from the atmosphere
@export var any_gas_modifier_per_tick: float
#endregion
#Things that are also important (for research specifically)
@export_multiline var description: String = "" ##The description that will showed up
@export var build_cost: int = 0 ##In terras
@export_range(0.0, 18_000, 0.1, "or_greater", "suffix:s")
var build_time: float = 0.0
@export_range(0, 100_000, 1, "or_greater", "suffix:Tr") var maintanence := 0 #in terras
@export_category("Optional (Can be inferred if left -1)")
@export var research_cost: int = -1
@export_range(-1, 36_000, 0.1, "or_greater", "suffix:s")
var research_time: float = -1

func get_modifiers() -> FacilityTransfer:
	var new_facility_transfer := FacilityTransfer.new()
	new_facility_transfer.name = name
	new_facility_transfer.category = category
	
	new_facility_transfer.terraform_modifier = terraform_modifier
	new_facility_transfer.terraform_modifier_per_tick = terraform_modifier_per_tick
	
	new_facility_transfer.city_modifier = city_modifier
	new_facility_transfer.city_modifier_per_tick = city_modifier_per_tick
	
	new_facility_transfer.any_atmosphere_modifier = any_gas_modifier_per_tick
	return new_facility_transfer
