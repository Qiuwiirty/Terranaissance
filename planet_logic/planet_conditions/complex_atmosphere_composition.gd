extends AtmosphereComposition
class_name ComplexAtmosphereComposition
#This is realllly complex q_q  , so it will be implemented in the future, probably
var default_color : Color = Color.SKY_BLUE
##If true: Planet atmosphere will be heavily affected by its "associated colors" which would give more variety
##If false: It will use planet color and apply little changes to how would that affect (More reallistic)
var enable_atmosphere_color_abstraction := true
var oxygen: float
var nitrogen: float
var carbon_dioxide: float
var sulfur_dioxide: float
var methane: float
var argon: float
var hydrogen: float
var helium: float
var other_inert_gases: float = 1_000_000 #Default
var other_toxic_gases: float
const GAS_COLORS : Array[Color] = [
	Color.AQUAMARINE,
	Color.BLUE,
	Color.RED,
	Color.YELLOW_GREEN,
	Color.SEA_GREEN,
	Color.WEB_PURPLE,
	Color.CADET_BLUE,
	Color.CHARTREUSE,
]
const GAS_NAMES : Array[StringName] = [
	&"oxygen",
	&"nitrogen",
	&"carbon_dioxide",
	&"sulfur_dioxide",
	&"methane",
	&"argon",
	&"hydrogen",
	&"helium",
	&"other_inert_gases",
	&"other_toxic_gases",
]
func add_gas(gas: StringName, amount: float) -> void:
	if amount <= 0.0:
		return
		
	var old_amount: float = get(gas)
	var total_other := 1_000_000 - old_amount
	
	amount = minf(amount, total_other)
	if amount <= 0.0:
		return
		
	var new_amount := old_amount + amount
	var scale := 1.0 - amount / total_other
	
	for other_gas in GAS_NAMES:
		if other_gas == gas:
			continue
			
		set(other_gas, get(other_gas) * scale)
	set(gas, new_amount)

func decrease_gas(gas: StringName, amount: float) -> void:
	if amount <= 0.0:
		return
		
	var old_amount: float = get(gas)
	var total_other := 1_000_000 - old_amount
	
	amount = minf(amount, old_amount)
	if amount <= 0.0:
		return
		
	var new_amount := old_amount - amount
	var scale := 1.0 + amount / total_other
	
	for other_gas in GAS_NAMES:
		if other_gas == gas:
			continue
			
		set(other_gas, get(other_gas) * scale)
		
	set(gas, new_amount)
func get_atmosphere_color() -> Color:
	if enable_atmosphere_color_abstraction:
		var gas_colors: Color = Color.BLACK
		for gas_color in GAS_COLORS:
			gas_colors += gas_color
		return gas_colors / 1_000_000
	return 0
func get_habitability() -> TerraformProperties.TerraformClassification:
	if oxygen >= 190000 and oxygen <= 220000:
		return TerraformProperties.TerraformClassification.PERFECT
		
	if oxygen >= 175000 and oxygen <= 275000:
		return TerraformProperties.TerraformClassification.HABITABLE
		
	if oxygen >= 150000 and oxygen <= 300000:
		return TerraformProperties.TerraformClassification.PLANT_LIFE
		
	if oxygen <= 400000:
		return TerraformProperties.TerraformClassification.MICROBE_LIFE
	
	if oxygen >= 900000:
		return TerraformProperties.TerraformClassification.HELLISH
	return TerraformProperties.TerraformClassification.BARREN
func add(other: SimpleAtmosphereComposition) -> void:
	oxygen += other.oxygen
	
func subtract(other: SimpleAtmosphereComposition) -> void:
	oxygen -= other.oxygen
	
func mutiply(other: AtmosphereComposition) -> void:
	oxygen *= other.oxygen
	
func mutiply_float(value: float) -> void:
	oxygen *= value
	
func get_elements() -> Dictionary[String, float]:
	return {
		"Oxygen": oxygen,
		"Nitrogen": nitrogen,
		"Carbon dioxide": carbon_dioxide,
		"Sulfur dioxide": sulfur_dioxide,
		"Methane": methane,
		"Argon": argon,
		"Hydrogen": hydrogen,
		"Helium": helium
	}
	
func get_custom_colors() -> Array[Color]:
	return GAS_COLORS
