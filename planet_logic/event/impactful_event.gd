extends Event
class_name ImpactfulEvent
@export var terraform_modifier_per_tick: TerraformProperties = TerraformProperties.new()
@export var terraform_modifier: TerraformProperties = TerraformProperties.new() # Only modify when initialized, unlike per tick. Usually for habitations and permanent things

@export var city_modifier_per_tick: CityProperties = CityProperties.new()
@export var city_modifier: CityProperties = CityProperties.new()
