extends CanvasLayer
class_name InGameUI
@onready var create_new_city_popup: CreateNewCityPopup = $CreateNewCity
func _ready() -> void:
	Game.in_game_ui = self
