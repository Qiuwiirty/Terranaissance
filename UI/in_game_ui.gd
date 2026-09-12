extends CanvasLayer
class_name InGameUI
@onready var create_new_city_popup: CreateNewCityPopup = $CreateNewCity
@onready var not_enough_money: NotEnoughMoneyPopup = $NotEnoughMoney
@onready var city_ui: CityUI = $CityUI
func _ready() -> void:
	Game.in_game_ui = self
	
