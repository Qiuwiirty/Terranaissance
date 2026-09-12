extends VBoxContainer
class_name FacilityItemUI
@onready var icon: TextureRect = %Icon
@onready var button: Button = %ButtonName
@onready var description: Label = %Description
var facility : Facility
func _ready() -> void:
	_update()

#this should not run per tick. it does not need to check if it's visible on screen or not because of it's exist temporarily
func _update() -> void: 
	icon.texture = Facility.CATEGORY_TO_TEXTURE[facility.category]
	button.text = facility.name
	description.text = facility.get_facform(false)
