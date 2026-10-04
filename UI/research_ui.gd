extends SimplePopup
@onready var technologies_ui: TechnologiesUI = $VBoxContainer/TechnologiesUI
func _ready() -> void:
	technologies_ui.update_available_facilities(true)
