@icon("uid://biuolv77yjw7r")
extends Resource
class_name EventData
@export var event : Event
## If set to 0.0, it will never happened
@export_range(0.0, 365.0, 0., "or_greater", "suffix:days") var average_interval_days := 0.0 
@export var is_global := false ##If global, it won't happen to specific cities.
@export var expert_only := false ##If true, only happen at expert mode 
