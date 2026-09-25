extends VBoxContainer
@onready var stats : Label = $Stats

func _ready() -> void:
	Game.planet.tick_timer.timeout.connect(_update)
	_update()
func _update() -> void:
	if !is_visible_in_tree():
		return
	stats.text = str(
		"Total population: ", str(Game.planet.total_population),"\n",
		"Habitations: ", str(Game.planet.total_habitation),"\n",
		"Habitability: ", Game.terra_classification_to_string(Game.planet.terraform_properties.get_habitability()),"\n",
		"Terras: ", str(Game.planet.planet_state.terras),"\n",
		"Cities: ", str(Game.planet.cities.size()))
