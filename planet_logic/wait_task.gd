extends Resource
class_name WaitTask
signal completed
var started_at: int
var duration: int
var _completed := false
func _init(duration_: int, custom_start_at := Time.get_unix_time_from_system()) -> void:
	started_at = int(custom_start_at)
	duration = duration_
func checkup() -> void:
	if _completed:
		return
	if Time.get_unix_time_from_system() - started_at >= duration:
		_completed = true
		completed.emit()
func get_elapsed() -> int:
	return int(Time.get_unix_time_from_system()) - started_at
func get_progress() -> float:
	return float(get_elapsed()) / duration
func get_time_left() -> int:
	return duration - get_elapsed()
