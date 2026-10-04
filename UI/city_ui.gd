extends SimplePopup
class_name CityUI
enum SelectMode {
	NONE,
	FACILITY,
	CREATE_NEW_FACILITY,
}
const FACILITY_ITEM_UI := preload("uid://3kya33kagpc7")
@onready var description : RichTextLabel = %Description
@onready var heading: HBoxContainer = %Heading
@onready var facilities_container: VBoxContainer = %FacilitiesContainer
@onready var facility_information: RichTextLabel = %FacInformation
@onready var facility_upgrade: Button = %FacUpgrade
@onready var facility_demolish: Button = %FacDemolish
@onready var add_new_facility: Button = %AddNewFacility
@onready var right_panel: PanelContainer = %RightPanel
@onready var create_new_facility: TechnologiesUI = %CreateNewFacility
@onready var are_you_sure: AreYouSure = $AreYouSure
var city: City
var select_mode: SelectMode = SelectMode.NONE
var _selected_facility: Facility

func _ready() -> void:
	_set_select_mode(SelectMode.NONE)
	
	Game.planet.tick_timer.timeout.connect(_update_heading)
	facility_upgrade.button_up.connect(_facility_upgrade)
	facility_demolish.button_up.connect(_facility_demolish)
	add_new_facility.button_up.connect(func() -> void: _set_select_mode(SelectMode.CREATE_NEW_FACILITY))
	create_new_facility.facility_data_selected.connect(_add_new_facility)

func open_city(city_: City) -> void:
	_set_select_mode(SelectMode.NONE)
	city = city_
	open()
	_update_heading()
	_update_facilities()
func _set_select_mode(mode: SelectMode) -> void:
	for child in right_panel.get_children(): child.hide()
	select_mode = mode
	match select_mode:
		SelectMode.FACILITY:
			%Facility.show()
		SelectMode.CREATE_NEW_FACILITY:
			%CreateNewFacilityScroll.show()
			create_new_facility.available_facility_data = city.planet.planet_state.researched_technologies
			create_new_facility.update_available_facilities()
			
func set_selected_facility(facility: Facility) -> void:
	_selected_facility = facility
	_set_select_mode(SelectMode.FACILITY)
	facility_information.text = """[center] {fac_name}
	[font_size=12] Level {level}
	[left] No description for this facility""".format(
			{"fac_name": facility.name,
			"level": facility.level})
func _update_heading() -> void:
	if !city:
		hide()
	if is_visible_in_tree():
		custom_minimum_size = heading.get_minimum_size() #update so panel don't look weird and adjusted to its children size
		description.text = str("[font_size=20][b]", city.name, " [/b][/font_size]",
		"\nPopulation: ", floori(city.properties.population),
		"\nHabitations: ", city.properties.habitations,
		"\nLat lon: ", snappedf(city.geoposition.x, 0.01), " and ", snappedf(city.geoposition.y, 0.01), ". Elevation: ", snappedf(city.geoposition.z , 0.01))
func _update_facilities() -> void:
	for facility in facilities_container.get_children(): 
		if facility.name != "AddNewFacility":
			facility.queue_free()
	for facility in city.facilities:
		var new_facility_item_ui: FacilityItemUI = FACILITY_ITEM_UI.instantiate()
		new_facility_item_ui.facility = facility
		facilities_container.add_child(new_facility_item_ui)
		new_facility_item_ui.button.button_up.connect(set_selected_facility.bind(facility))
func _facility_upgrade() -> void:
	_selected_facility.set_level(_selected_facility.level + 1)
func _facility_demolish() -> void:
	_selected_facility.delete()
func _add_new_facility(facility_data: FacilityData) -> void:
	var is_confirmed := await are_you_sure.request_confirmation("Build?", "Are you want to build? This will cost {price} Tr!".format({"price": facility_data.build_cost}))
	if is_confirmed:
		city.facilities.append(Facility.new(city, facility_data.get_modifiers()))
	_update_facilities()
