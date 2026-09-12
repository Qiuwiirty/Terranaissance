extends HBoxContainer
var facility : Facility
func _ready() -> void:
	_update()

func _update() -> void:
	if is_visible_in_tree(): #visible only account for its visibility, while this take account of its parents
		pass
