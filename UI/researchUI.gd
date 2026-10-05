@tool
extends TechnologiesUI
class_name ResearchUI
@onready var confirm_research : AreYouSure = %AreYouSureResearch
func _ready() -> void:
	update_available_facilities(true)
	facility_data_selected.connect(_facility_research_selected)

func _facility_research_selected(facility_data: FacilityData) -> void:
	var is_confirmed := await confirm_research.request_confirmation("Confirm research?", "This will cost {cost} and will take {time}. Do you wish to proceed?".format({
		"cost": facility_data.research_cost,
		"time": Game.format_time_timer(facility_data.research_time),
	}))
	if is_confirmed:
		var new_wait_task := WaitTask.new(facility_data.research_time)
		new_wait_task.completed.connect(_research_completed.bind(facility_data))
		Game.planet.append_wait_task(new_wait_task)
		
func _research_completed(facility_data: FacilityData) -> void:
	Game.planet.planet_state.researched_technologies.append(facility_data)
