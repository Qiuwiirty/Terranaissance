extends MarginContainer
class_name CultureAxisControl
var culture: Culture.Cultures = Culture.Cultures.TERRAFORM
@onready var culture_value_rect : ColorRect = %CultureValueRect
@onready var culture_value : Label = %Value
func define_culture(opposite_culture: String, supporting_culture: String, culture_: Culture.Cultures) -> void:
	%OppositeSpectrum.text = opposite_culture
	%Spectrum.text = supporting_culture
	culture = culture_
	set_culture_value(Game.planet.planet_state.culture.get_value(culture))
## Update things through here
func set_culture_value(value: float) -> void:
	if signf(value) == 1.0: #positive
		culture_value_rect.anchor_left = 0.5
		culture_value_rect.anchor_right = 0.5 + value / Culture.MAX_CULTURE_VALUE
	else: #negative
		culture_value_rect.anchor_right = 0.5
		culture_value_rect.anchor_left = 0.5 - value / Culture.MAX_CULTURE_VALUE
	culture_value.text = str(value)
