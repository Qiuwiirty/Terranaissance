extends VBoxContainer
@onready var terraform_axis: CultureAxisControl = $AxisGrid/Terraform
@onready var centralized_axis: CultureAxisControl = $AxisGrid/Terraform
@onready var economy_axis: CultureAxisControl = $AxisGrid/Economy
@onready var experimental_axis: CultureAxisControl = $AxisGrid/Experimental
func _ready() -> void:
	terraform_axis.define_culture("Industrial", "Terraform", Culture.Cultures.TERRAFORM)
	centralized_axis.define_culture("Decentralized", "Centralized", Culture.Cultures.CENTRALIZED)
	economy_axis.define_culture("Science", "Economy", Culture.Cultures.ECONOMY)
	experimental_axis.define_culture("Protocol", "Experimental", Culture.Cultures.EXPERIMENTAL)
