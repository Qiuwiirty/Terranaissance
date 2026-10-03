extends VBoxContainer
class_name FacilityDataItemUI ##It is just FacilityItemUI but use FacilityData
@onready var icon: TextureRect = %Icon
@onready var button: Button = %ButtonName
@onready var description: Label = %Description
@onready var price_label: Label = %Price
@export var facility_data : FacilityData
@export var price_mode: TechnologiesUI.PriceShow
func _ready() -> void:
	_update()
	
#this should not run per tick. it does not need to check if it's visible on screen or not because of it's exist temporarily
func _update() -> void: 
	icon.texture = Facility.CATEGORY_TO_TEXTURE[facility_data.category]
	button.text = facility_data.name
	description.text = facility_data.description
	if price_mode != TechnologiesUI.PriceShow.NONE:
		price_label.text = str(facility_data.research_cost if price_mode == TechnologiesUI.PriceShow.RESEARCH else facility_data.build_cost) + " Tr"
