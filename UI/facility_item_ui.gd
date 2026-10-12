extends VBoxContainer
class_name FacilityItemUI
@onready var icon: TextureRect = %Icon
@onready var button: Button = %ButtonName
@onready var info: Label = %Info
@export var any_gas: Gas
var facility : Facility
@export var icon_scale := 3.0

func _ready() -> void:
	_update()
	icon.custom_maximum_size = Vector2(40, 40) * icon_scale
#this should not run per tick. it does not need to check if it's visible on screen or not because of it's exist temporarily
func _update() -> void: 
	icon.texture = Facility.CATEGORY_TO_TEXTURE[facility.category]
	button.text = facility.name + " " + str(facility.level)
	info.text = Game.get_modifier_descriptions(facility.get_modifiers(), "Any gas" if !any_gas else any_gas.name)
	
