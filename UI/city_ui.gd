extends SimplePopup
class_name CityUI
@onready var description : RichTextLabel = %Description
@onready var heading: HBoxContainer = %Heading
var city: City
func _ready() -> void:
	Game.planet.tick_timer.timeout.connect(_update_heading)
func open_city(city_: City) -> void:
	city = city_
	open()
	_update_heading()
func _update_heading() -> void:
	custom_minimum_size = heading.get_minimum_size() #update so panel don't look weird and adjusted to its children size
	if is_visible_in_tree():
		description.text = str("[font_size=20][b]", city.name, " [/b][/font_size]",
		"\nPopulation: ", city.properties.population,
		"\nHabitations: ", city.properties.habitations,
		"\nLat lon: ", city.geoposition.x, " and ", city.geoposition.y, ". Elevation: ", city.geoposition.z)
