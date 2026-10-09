@tool
extends TechnologiesUI
class_name ResearchUI
const WAIT_TASK_UI := preload("uid://cdcdv03hk3xut")
var research_completed_event : EventData = load("uid://bcwbsibu456js")
@onready var confirm_research : AreYouSure = %AreYouSureResearch
@onready var research_wait_task_container: VBoxContainer = $ResearchWaitTaskContainer
func _ready() -> void:
	update_available_facilities(true)
	facility_data_selected.connect(_facility_research_selected)
	for facility_data in Game.planet.planet_state.researched_technologies:
		disabled_facilities.append(facility_data.name)
	disable_facility_data()
func _facility_research_selected(facility_data: FacilityData) -> void:
	var is_confirmed := await confirm_research.request_confirmation("Confirm research?", "This will cost {cost} and will take {time}. Do you wish to proceed?".format({
		"cost": facility_data.research_cost,
		"time": Game.format_time_timer(facility_data.research_time),
	}))
	if is_confirmed:
		var new_wait_task := WaitTask.new(facility_data.research_time)
		new_wait_task.completed.connect(_research_completed.bind(facility_data))
		Game.planet.append_wait_task(new_wait_task)
		var new_wait_task_ui: WaitTaskUI = WAIT_TASK_UI.instantiate()
		new_wait_task_ui.wait_task = new_wait_task
		new_wait_task_ui.head_text = "Researching " + facility_data.name
		new_wait_task.completed.connect(new_wait_task_ui.queue_free)
		var new_research_completed_event : Event = research_completed_event.event
		new_research_completed_event.description = new_research_completed_event.description.format({"research": facility_data.name})
		new_wait_task.completed.connect(Game.in_game_ui.event_popup.open_popup_event.bind(new_research_completed_event))
		research_wait_task_container.add_child(new_wait_task_ui)
func _research_completed(facility_data: FacilityData) -> void:
	Game.planet.planet_state.researched_technologies.append(facility_data)
	disabled_facilities.append(facility_data.name)
	disable_facility_data()
