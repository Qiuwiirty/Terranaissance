extends PanelContainer

func _ready() -> void:
	%PlanetName.text = Game.planet.planet_properties.name
func _on_view_mode_selected(_index: int) -> void:
	pass #For now there only one mode
func _on_enable_sun_light_toggled(toggled_on: bool) -> void:
	Game.sun.set_sun_visibility(toggled_on)
func _on_sun_rotation_toggled(toggled_on: bool) -> void:
	Game.sun.rotate_light = toggled_on
