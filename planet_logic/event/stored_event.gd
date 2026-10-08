extends Resource
class_name StoredEvent
@export var event: Event
@export_range(0, 100_000, 1, "or_greater", "suffix: in days") var stored_time: int
