extends VBoxContainer
class_name FacilityItemUI
@onready var icon: TextureRect = %Icon
@onready var button: Button = %ButtonName
@onready var description: Label = %Description
var facility : Facility
func _ready() -> void:
	_update()
	button.button_up.connect(_button_up)
#this should not run per tick. it does not need to check if it's visible on screen or not because of it's exist temporarily
func _update() -> void: 
	icon.texture = Facility.CATEGORY_TO_TEXTURE[facility.category]
	button.text = facility.name
	description.text = facility.get_facform(false)
func _button_up() -> void:
	Game.in_game_ui.city_ui.set_selected_facility(facility)
