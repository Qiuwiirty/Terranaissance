@tool
extends PanelContainer
class_name TechnologiesUI
@onready var tech_containers : VBoxContainer = $ScrollContainer/TechContainers
@onready var head : RichTextLabel = $ScrollContainer/TechContainers/Head
@export_multiline var head_info : String:
	set(str):
		head.text = str
	get:
		return head.text
@export var run: bool:
	set(v):
		create_categories()
func create_categories() -> void:
	if Engine.is_editor_hint():
		for child in tech_containers.get_children():
			if child.name != "Head":
				child.queue_free()
		for category in Facility.Category.values():
			var new_rich_text_label := RichTextLabel.new()
			new_rich_text_label.add_image(Facility.CATEGORY_TO_TEXTURE[category], 50.)
			new_rich_text_label.append_text("[b][font_size=25] %s" % Facility.Category.keys()[category].replace("_", " ").capitalize())
			new_rich_text_label.fit_content = true
			
			tech_containers.add_child(new_rich_text_label)
			new_rich_text_label.owner = get_tree().edited_scene_root
		notify_property_list_changed()
