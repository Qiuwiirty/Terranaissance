extends SimplePopup
class_name CreateNewCityPopup
func request_create_new_city_name(coords: Vector3) -> String:
	open()
	$VBoxContainer/CityInfo.text = str(
		"Coordinates: ", coords.x, ", ", coords.y, "\n",
		"Elevation:", (coords.z -  Game.planet.terraform_properties.water) / 1000., " km above sea level",
		"\n(", coords, ")"
	)
	await %Create.button_up
	close()
	return %CityNameInput.text
