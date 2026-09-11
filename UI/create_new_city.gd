extends SimplePopup
class_name CreateNewCityPopup
func close() -> void:
	super()
	Game.planet.in_creating_city = false
func request_create_new_city_name(coords: Vector3, price: float) -> String:
	open()
	$VBoxContainer/CityInfo.text = str(
		"Coordinates: ", coords.x, ", ", coords.y, "\n",
		"Elevation:", (coords.z -  Game.planet.terraform_properties.water) / 1000., " km above sea level",
		"\n(", coords, ")",
		"\n Going to cost ", price, " Tr" 
	)
	await %Create.button_up
	Game.terras -= price
	close()
	return %CityNameInput.text
