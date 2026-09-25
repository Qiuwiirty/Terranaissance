extends VBoxContainer
@onready var target_classification_option : OptionButton = $TargetClassificationOptionContainer/OptionButton
@onready var piechart: PieChart = $PieChart
var donut_redraw := false
func _ready() -> void:
	target_classification_option.selected = 2
	for terraform_indicator: Control in get_children():
		if terraform_indicator is not TerraformIndicator:
			continue
		terraform_indicator.target_life_classification = TerraformProperties.TerraformClassification.HABITABLE
		terraform_indicator.terraform_properties = Game.planet.terraform_properties
		terraform_indicator.planet_properties = Game.planet.planet_properties
		terraform_indicator._update()
	Game.planet.tick_timer.timeout.connect(_update)
func _update() -> void:
	if visible:
		var atmosphere_composition: AtmosphereComposition = Game.planet.terraform_properties.atmosphere_composition
		var elements = atmosphere_composition.get_elements()
		if elements.values().any(func(value): return is_zero_approx(value)):
			if !donut_redraw:
				piechart.set_new_data({"None": 1_000_000.})
				piechart.doughnut_shape = true
				piechart.center_text = "No oxygen or pressure.."
				piechart.queue_redraw()
				donut_redraw = true
			return
		donut_redraw = false
		piechart.doughnut_shape = false
		piechart.set_new_data(Game.planet.terraform_properties.atmosphere_composition.get_elements())
		piechart.custom_scale = Game.planet.terraform_properties.atmosphere_composition.get_custom_colors()
func _update_terraform_indicator_target_life(target: TerraformProperties.TerraformClassification) -> void:
	for terraform_indicator: Control in get_children():
		if terraform_indicator is not TerraformIndicator:
			continue
		terraform_indicator.target_life_classification = target
		terraform_indicator._update()
func _on_target_environment_classification_selected(index: int) -> void:
	match index:
		0: #Microbial life
			_update_terraform_indicator_target_life(TerraformProperties.TerraformClassification.MICROBE_LIFE)
		1: #Plant life
			_update_terraform_indicator_target_life(TerraformProperties.TerraformClassification.PLANT_LIFE)
		2: #Human life
			_update_terraform_indicator_target_life(TerraformProperties.TerraformClassification.HABITABLE)
