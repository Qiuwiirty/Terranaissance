extends SimplePopup
class_name AreYouSure
signal action(confirmed: bool)
@onready var yes: Button = %Yes
@onready var no: Button = %No
@onready var title_label : Label =  %Title
@onready var info_label : Label = %Info
func _ready() -> void:
	yes.button_up.connect(func() -> void: action.emit(true))
	no.button_up.connect(func() -> void: action.emit(false))
func request_confirmation(title: String, info: String, yes_text := "Yes", no_text := "No") -> bool:
	open()
	title_label.text = title
	info_label.text = info
	yes.text = yes_text
	no.text = no_text
	var is_confirmed : bool = await action
	close()
	return is_confirmed
