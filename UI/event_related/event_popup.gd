extends SimplePopup
class_name EventPopup
@onready var title_label : Label = %Title
@onready var description_label : RichTextLabel = %Description
@onready var buttons_container: HBoxContainer = %Buttons
## Second argument is optional and will default to normal OK button, unless specify to add other options
func open_popup_event(event: Event, event_buttons: Array[EventPopupButton] = [EventPopupButton.new("OK")]) -> void:
	title_label.text = event.title
	description_label.text = event.description
	for event_button: EventPopupButton in event_buttons:
		var new_button := Button.new()
		new_button.text = event_button.text
		new_button.button_up.connect(close)
		if event_button.button_up_callable:
			new_button.button_up.connect(event_button.button_up_callable)
		new_button.size_flags_horizontal = Control.SIZE_FILL
		buttons_container.add_child(new_button)
