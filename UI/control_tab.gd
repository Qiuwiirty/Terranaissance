extends SimplePopup
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_TAB:
			if !visible:
				open()
			else:
				hide()
