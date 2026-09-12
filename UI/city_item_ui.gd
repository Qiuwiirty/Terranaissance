extends PanelContainer
class_name CityItemUI

var city: City

func _ready() -> void:
	Game.planet.tick_timer.timeout.connect(_update)
	_update()
	%CityButton.text = city.name
func _update() -> void:
	if is_visible_in_tree():
		%Population.text = "Population: " + str(floori(city.properties.population))
		
func _on_city_button_up() -> void:
	Game.in_game_ui.city_ui.open_city(city)
