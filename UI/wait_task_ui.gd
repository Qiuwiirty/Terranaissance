extends VBoxContainer
class_name WaitTaskUI
var wait_task: WaitTask
var head_text: String
@onready var head : RichTextLabel = $Head
@onready var time_left: Label = $TimeLeft
@onready var progress: ColorRect = $Progress
func _ready() -> void:
	Game.planet.tick_timer.timeout.connect(_update)
	head.text = head_text
	wait_task.completed.connect(queue_free)
	_update()
func _update() -> void:
	time_left.text = "Time left: " + Game.format_time_timer(wait_task.get_time_left())
	if is_visible_in_tree():
		progress.offset_transform_scale.x = wait_task.get_progress()
