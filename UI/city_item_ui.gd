extends PanelContainer
class_name CityItemUI

var city: City

func _update() -> void:
	%Population.text = "Population: " + str(floori(city.properties.population))
