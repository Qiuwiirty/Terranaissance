extends Resource
class_name EventData
@export var event : Event
@export_range(0.0, 365.0, 0., "or_greater", "suffix: in days") var probability_in_days := 0.0 
