extends MarginContainer
static var character_length: float
var category : Facility.Category = Facility.Category.PRESSURE
@onready var icon: TextureRect = %Icon
@onready var arrow_indicator : Label = %ArrowIndicator
@onready var min_habitability : Label = %MinHabitability
@onready var max_habitability : Label= %MaxHabitability
func _ready() -> void:
	if !character_length:
		character_length = arrow_indicator.get_theme_font("font").get_string_size(arrow_indicator.text).x
	arrow_indicator.offset_transform_position.x = -character_length / 2
	icon.texture = Facility.CATEGORY_TO_TEXTURE[category]
func _update() -> void:
	icon.modulate
