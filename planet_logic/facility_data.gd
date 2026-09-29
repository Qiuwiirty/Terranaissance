extends Resource
class_name FacilityData
## FacilityData allow facform, description and price metadata

## Construct property modifiers in a human readable format in string (I called it facform lol). Format is: "property operation value, property ..." (Operation: (+ add, - subtract. ++ add per tick, -- subtract per tick))
##
## It's constructed in 2 part. "metadata. modifiers" like for example "name=Cooler Alpha, category=TEMPERATURE.-- 4 heat, + 2 habitations"
## For enum, you must input int and not string like PRESSURE (instead 1). You may use (pre-defined) aliases. See the code
@export_multiline var facform: String
@export_multiline var description: String = "" ##The description that will showed up
@export var price: int = 0 ##In terras
@export_range(0.0, 18_000, 0.1, "or_greater", "suffix:s")
var build_time: float = 10
