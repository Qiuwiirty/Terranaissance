extends MarginContainer
class_name TerraformIndicator
static var character_length: float
var terraform_properties: TerraformProperties
var planet_properties: PlanetProperties
@export var category : Facility.Category = Facility.Category.TEMPERATURE #Atmosphere is a special case, it should use pie chart (if simple then just show one of the properties)
##This is basically the "indicator for what type of life". If, it's plant life, then it will set its min and max to the plant life, and even if microbe life can hold the condition, it will stay red (showed cannot support) if plant can't support it 
@export var target_life_classification: TerraformProperties.TerraformClassification =TerraformProperties.TerraformClassification.PLANT_LIFE
@onready var icon: TextureRect = %Icon
@onready var arrow_indicator : Label = %ArrowIndicator
@onready var min_habitability : Label = %MinHabitability
@onready var max_habitability : Label = %MaxHabitability
@onready var progress: TextureRect = $HBoxContainer/Control/Progress
func _ready() -> void:
	progress.texture = progress.texture.duplicate()
	if !character_length:
		character_length = arrow_indicator.get_theme_font("font").get_string_size(arrow_indicator.text).x
	arrow_indicator.offset_transform_position.x = -character_length / 2
	icon.texture = Facility.CATEGORY_TO_TEXTURE[category]
	match category:
		Facility.Category.WATER:
			progress.texture.gradient = load("uid://cer3hf20ku6i3")
		Facility.Category.BIOMASS:
			progress.texture.gradient = load("uid://dlbrskmkwycy6")
	Game.planet.tick_timer.timeout.connect(_update)
func _update() -> void:
	#i write this code sleepily, apologise for the weird-ity
	var var_name : String = Facility.Category.keys()[category].to_lower()
	if !TerraformProperties.HABITABILITY_RANGES[target_life_classification].has(var_name):
		hide()
		return
	show()
	var var_value : Variant = TerraformProperties.HABITABILITY_RANGES[target_life_classification][var_name]
	if var_value is Vector2:
		var min_hab := roundi(var_value.x)
		var max_hab := roundi(var_value.y)
		var current_value : float = terraform_properties.get(var_name)
		
		min_habitability.text = Game.humanize_number(str(min_hab))
		max_habitability.text = Game.humanize_number(str(max_hab))
		
		arrow_indicator.offset_transform_position_ratio.x = clamp((current_value - min_hab) / float(max_hab - min_hab), 0.0, 1.0)
	else: # must be a float
		match var_name:
			"water":
				var min_hab : float = var_value * planet_properties.max_elevation
				var max_hab : float = planet_properties.max_elevation * 0.75
				var current_value: float = terraform_properties.water
				
				min_habitability.text = Game.humanize_number(str(roundi(min_hab)))
				max_habitability.text = Game.humanize_number(str(roundi(max_hab)))
				
				arrow_indicator.offset_transform_position_ratio.x = clampf(
					(current_value - min_hab) / float(max_hab - min_hab), 0.0, 1.0)
				
			"biomass":
				var min_hab : float = var_value * planet_properties.max_biomass
				var max_hab : float = planet_properties.max_biomass
				var current_value: float = terraform_properties.biomass
				
				min_habitability.text = Game.humanize_number(str(roundi(min_hab)))
				max_habitability.text = Game.humanize_number(str(roundi(max_hab)))
				
				arrow_indicator.offset_transform_position_ratio.x = clampf(
					(current_value - min_hab) / float(max_hab - min_hab), 0.0, 1.0)
	var habitability := _get_habitability()
	if habitability < target_life_classification:
		icon.modulate = Color.RED
		return
	match habitability:
		TerraformProperties.TerraformClassification.BARREN:
			icon.modulate = Color.RED
		TerraformProperties.TerraformClassification.MICROBE_LIFE:
			icon.modulate = Color.MEDIUM_BLUE
		TerraformProperties.TerraformClassification.PLANT_LIFE:
			icon.modulate = Color.DARK_ORANGE
		TerraformProperties.TerraformClassification.HABITABLE:
			icon.modulate = Color(255, 190, 0)
		TerraformProperties.TerraformClassification.PERFECT:
			icon.modulate = Color.GREEN
func get_temperature_habitability() -> TerraformProperties.TerraformClassification:
	for classification in [
		TerraformProperties.TerraformClassification.PERFECT,
		TerraformProperties.TerraformClassification.HABITABLE,
		TerraformProperties.TerraformClassification.PLANT_LIFE,
		TerraformProperties.TerraformClassification.MICROBE_LIFE,
	]:
		var range_value: Vector2 = TerraformProperties.HABITABILITY_RANGES[classification]["temperature"]
		
		if Game.is_in_range(terraform_properties.temperature, range_value):
			return classification
	return TerraformProperties.TerraformClassification.BARREN
func get_pressure_habitability() -> TerraformProperties.TerraformClassification:
	for classification in [
		TerraformProperties.TerraformClassification.PERFECT,
		TerraformProperties.TerraformClassification.HABITABLE,
		TerraformProperties.TerraformClassification.PLANT_LIFE,
		TerraformProperties.TerraformClassification.MICROBE_LIFE,
	]:
		var range_value: Vector2 = TerraformProperties.HABITABILITY_RANGES[classification]["pressure"]
		if Game.is_in_range(terraform_properties.pressure, range_value):
			return classification
	return TerraformProperties.TerraformClassification.BARREN
func get_water_habitability() -> TerraformProperties.TerraformClassification:
	var current_habitable_water_level := terraform_properties.water / planet_properties.habitable_water_level
	for classification in [
		TerraformProperties.TerraformClassification.PERFECT,
		TerraformProperties.TerraformClassification.HABITABLE,
		TerraformProperties.TerraformClassification.PLANT_LIFE,
		TerraformProperties.TerraformClassification.MICROBE_LIFE,
	]:
		var habitable_water_level_ratio: float = TerraformProperties.HABITABILITY_RANGES[classification]["water"]
		if current_habitable_water_level >= habitable_water_level_ratio:
			return classification
	return TerraformProperties.TerraformClassification.BARREN
func get_biomass_habitability() -> TerraformProperties.TerraformClassification:
	var current_biomass_ratio := terraform_properties.biomass / planet_properties.max_biomass
	for classification in [
		TerraformProperties.TerraformClassification.PERFECT,
		TerraformProperties.TerraformClassification.HABITABLE,
		TerraformProperties.TerraformClassification.PLANT_LIFE,
		TerraformProperties.TerraformClassification.MICROBE_LIFE,
	]:
		if !TerraformProperties.HABITABILITY_RANGES[classification].has("biomass"):
			continue
		var habitable_biomass_ratio: float = TerraformProperties.HABITABILITY_RANGES[classification]["biomass"]
		if current_biomass_ratio >= habitable_biomass_ratio:
			return classification
	return TerraformProperties.TerraformClassification.BARREN
func _get_habitability() -> TerraformProperties.TerraformClassification:
	match category:
		Facility.Category.TEMPERATURE:
			return get_temperature_habitability()
		Facility.Category.PRESSURE:
			return get_pressure_habitability()
		Facility.Category.WATER:
			return get_water_habitability()
		Facility.Category.BIOMASS:
			return get_biomass_habitability()
		Facility.Category.ATMOSPHERE:
			return terraform_properties.atmosphere_composition.get_habitability()
		_:
			push_error("Unrecognized category..,")
			return 0
