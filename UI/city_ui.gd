extends SimplePopup
class_name CityUI
const FACILITY_ITEM_UI := preload("uid://3kya33kagpc7")
@onready var description : RichTextLabel = %Description
@onready var heading: HBoxContainer = %Heading
@onready var facilities_container: VBoxContainer = %FacilitiesContainer
var city: City
func _ready() -> void:
	Game.planet.tick_timer.timeout.connect(_update_heading)
func open_city(city_: City) -> void:
	city = city_
	open()
	_update_heading()
	_update_facilities()
func _update_heading() -> void:
	if is_visible_in_tree():
		custom_minimum_size = heading.get_minimum_size() #update so panel don't look weird and adjusted to its children size
		description.text = str("[font_size=20][b]", city.name, " [/b][/font_size]",
		"\nPopulation: ", city.properties.population,
		"\nHabitations: ", city.properties.habitations,
		"\nLat lon: ", city.geoposition.x, " and ", city.geoposition.y, ". Elevation: ", city.geoposition.z)
func _update_facilities() -> void:
	for facility in facilities_container.get_children(): facility.queue_free()
	for facility in city.facilities:
		var new_facility_item_ui: FacilityItemUI = FACILITY_ITEM_UI.instantiate()
		new_facility_item_ui.facility = facility
		facilities_container.add_child(new_facility_item_ui)
