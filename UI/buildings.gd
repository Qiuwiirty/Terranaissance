extends PanelContainer
const CITY_ITEM_UI := preload("uid://cfffhw6tfjqqv")
@onready var cities := %Cities
func _ready() -> void:
	Game.planet.city_created.connect(_update_cities)

func _update_cities(_created_city: City) -> void:
	#This is unoptimized but i gonna fixed it later..
	for child in cities.get_children(): child.queue_free()
	for city in Game.planet.cities:
		var new_city_item_ui: CityItemUI = CITY_ITEM_UI.instantiate()
		new_city_item_ui.city = city
		cities.add_child(new_city_item_ui)
