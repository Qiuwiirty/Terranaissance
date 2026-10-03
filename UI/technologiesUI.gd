@tool
extends PanelContainer
class_name TechnologiesUI
enum PriceShow {
	NONE,
	RESEARCH,
	BUILD
}
const FACILITY_DATA_ITEM_UI := preload("uid://2oamdxx0a6o4")
@onready var tech_containers : VBoxContainer = $ScrollContainer/TechContainers
@onready var head : RichTextLabel = $ScrollContainer/TechContainers/Head
@export_multiline var head_info : String:
	set(str):
		if is_node_ready():
			head.text = str
	get:
		if is_node_ready():
			return head.text
		return "ERROR: NODE NOT READY.."
@export var price_mode := PriceShow.BUILD
@export var available_facility_data: Array[FacilityData]
@export var run: bool:
	set(v):
		if Engine.is_editor_hint():
			create_categories()
#This prepare the categories text and container
func _ready() -> void:
	update_available_facilities()
func create_categories() -> void:
	if Engine.is_editor_hint():
		for child in tech_containers.get_children():
			if child.name != "Head":
				child.queue_free()
		await get_tree().process_frame
		for category in Facility.Category.values():
			var category_name : String = Facility.Category.keys()[category].capitalize()
			var new_rich_text_label := RichTextLabel.new()
			#TIL that capitalize also remove -, and _. Sweet!
			#Append text or append image does not work
			new_rich_text_label.text = "[img=40]{img_dir}[/img][b][font_size=20] {category}".format({"img_dir": Facility.CATEGORY_TO_TEXTURE[category].resource_path, "category": category_name})
			new_rich_text_label.bbcode_enabled = true
			new_rich_text_label.fit_content = true
			new_rich_text_label.name = category_name.replace(" ", "") #just remove space
			tech_containers.add_child(new_rich_text_label, true)
			new_rich_text_label.owner = get_tree().edited_scene_root
			var new_container := VBoxContainer.new()
			
			tech_containers.add_child(new_container)
			new_container.name = category_name.replace(" ", "") + "Container"
			new_container.owner = get_tree().edited_scene_root
			
func update_available_facilities() -> void:
	####TODO: USE FACILITY ITEM UI, ADD OPTIONAL PRICE
	#prepare first..
	var category_to_facility_data : Dictionary[Facility.Category, Array]
	for facility_data in available_facility_data:
		if not category_to_facility_data.has(facility_data.category):
			category_to_facility_data[facility_data.category] = []
		category_to_facility_data[facility_data.category].append(facility_data)
	for category in Facility.Category.values():
		var category_container_name : String = Facility.Category.keys()[category].capitalize().replace(" ", "") + "Container"
		var category_container : VBoxContainer = tech_containers.get_node_or_null(category_container_name)
		if category_container and category_to_facility_data.has(category):
			for facility_data: FacilityData in category_to_facility_data[category]:
				var new_facility_data_item_ui: FacilityDataItemUI = FACILITY_DATA_ITEM_UI.instantiate()
				new_facility_data_item_ui.facility_data = facility_data
				new_facility_data_item_ui.price_mode = price_mode
				category_container.add_child(new_facility_data_item_ui)
