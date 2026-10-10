extends PanelContainer
const CITY_ITEM_UI := preload("uid://cfffhw6tfjqqv")
@onready var cities := %Cities

@onready var expand_collapse_button: TextureButton = $ExpandCollapseButton
@onready var buildings_container := $BuildingsContainer
func _ready() -> void:
	Game.planet.city_created.connect(_update_cities)
	expand_collapse_button.button_up.connect(expand_or_collapse)
func expand_or_collapse() -> void:
	var new_tween := create_tween()
	new_tween.set_ease(Tween.EASE_IN)
	if !buildings_container.visible:
		buildings_container.show()
		new_tween.set_parallel(true)
		new_tween.tween_property(expand_collapse_button, "offset_transform_rotation", 0.0, Game.ANIM_SPEED)
		#new_tween.tween_property(expand_collapse_button, "offset_transform_position_ratio", )
		new_tween.tween_property(self, "offset_transform_position_ratio:x", 0.0, Game.ANIM_SPEED)
		new_tween.set_parallel(false)
	else:
		new_tween.set_parallel(true)
		new_tween.tween_property(expand_collapse_button, "offset_transform_rotation:", deg_to_rad(90.0), Game.ANIM_SPEED)
		new_tween.tween_property(self, "offset_transform_position_ratio:x", 1.0, Game.ANIM_SPEED)
		new_tween.set_parallel(false)
		new_tween.tween_callback(buildings_container.hide)

func _update_cities(_created_city: City) -> void:
	#This is unoptimized but i gonna fixed it later..
	for child in cities.get_children(): child.queue_free()
	for city in Game.planet.cities:
		var new_city_item_ui: CityItemUI = CITY_ITEM_UI.instantiate()
		new_city_item_ui.city = city
		cities.add_child(new_city_item_ui)
		
