extends MarginContainer
static var character_length: float
var terraform_properties: TerraformProperties
var planet_properties: PlanetProperties
@export var category : Facility.Category = Facility.Category.TEMPERATURE
@onready var icon: TextureRect = %Icon
@onready var arrow_indicator : Label = %ArrowIndicator
@onready var min_habitability : Label = %MinHabitability
@onready var max_habitability : Label= %MaxHabitability
func _ready() -> void:
	if !character_length:
		character_length = arrow_indicator.get_theme_font("font").get_string_size(arrow_indicator.text).x
	arrow_indicator.offset_transform_position.x = -character_length / 2
	icon.texture = Facility.CATEGORY_TO_TEXTURE[category]
	Game.planet.tick_timer.timeout.connect(_update)
func _update() -> void:
	var habitability := _get_habitability()
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
