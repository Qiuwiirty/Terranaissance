extends RefCounted
class_name EventPopupButton

var text: String
var button_up_callable: Callable

func _init(text_: String, button_up_callable_: Callable = Callable()) -> void:
	text = text_
	button_up_callable = button_up_callable_
