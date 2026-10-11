extends OptionButton
class_name AnyGasOptionButton
signal gas_selected(gas: Gas)
func _ready() -> void:
	item_selected.connect(_on_item_selected)
	#any gas
	for gas in Game.planet.gases:
		add_item(gas)

func _on_item_selected(index: int) -> void:
	var gas_name := get_item_text(index)
	assert(gas_name in Game.planet.gases)
	gas_selected.emit(Game.planet.gases[gas_name])
