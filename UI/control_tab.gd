extends TabContainer
@onready var environment_container : VBoxContainer = $ScrollContainer/EnvironmentContainer
@onready var target_classification_option : OptionButton = $ScrollContainer/EnvironmentContainer/TargetClassificationOptionContainer/OptionButton
func _ready() -> void:
	target_classification_option.selected = 2
	for terraform_indicator: Control in environment_container.get_children():
		if terraform_indicator is not TerraformIndicator:
			continue
		terraform_indicator.target_life_classification = TerraformProperties.TerraformClassification.HABITABLE
		terraform_indicator.terraform_properties = Game.planet.terraform_properties
		terraform_indicator.planet_properties = Game.planet.planet_properties
		terraform_indicator._update()
func _update_terraform_indicator_target_life(target: TerraformProperties.TerraformClassification) -> void:
	for terraform_indicator: Control in environment_container.get_children():
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
