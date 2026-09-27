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
var carbon_monoxide: float
var ammonia: float
var other_inert_gases: float = 1_000_000 #Default
var other_toxic_gases: float

var gasses: Dictionary[Gas, float]
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
	&"carbon_monoxide",
	&"ammonia",
	&"other_inert_gases",
	&"other_toxic_gases",
]
const HABITABILITY_RANGES : Dictionary[TerraformProperties.TerraformClassification, Dictionary] = {
	TerraformProperties.TerraformClassification.PERFECT: 
		{
			&"oxygen": Vector2(190_000, 220_000),
			&"carbon_dioxide": Vector2(300, 1000),
			&"methane": Vector2(0, 1000),
			&"sulfur_dioxide": Vector2(0, 1),
			&"other_toxic_gases": Vector2(0, 5),
			&"carbon_monoxide": Vector2(0, 10),
			&"ammonia": Vector2(0, 25),
		},
	TerraformProperties.TerraformClassification.HABITABLE: 
		{
			&"oxygen": Vector2(175_000, 275_000),
			&"methane": Vector2(0, 50_000),
			&"carbon_dioxide": Vector2(200, 10_000),
			&"sulfur_dioxide": Vector2(0, 5),
			&"other_toxic_gases": Vector2(0, 10),
			&"carbon_monoxide": Vector2(0, 35),
			&"ammonia": Vector2(0, 50),
		},
	TerraformProperties.TerraformClassification.PLANT_LIFE: 
		{
			&"oxygen": Vector2(150_000, 300_000),
			&"carbon_dioxide": Vector2(200, 50_000),
			&"sulfur_dioxide": Vector2(0, 15),
			&"methane": Vector2(0, 50_000),
			&"other_toxic_gases": Vector2(0, 25),
			&"carbon_monoxide": Vector2(0, 20_000),
			&"ammonia": Vector2(0, 500),
		},
	TerraformProperties.TerraformClassification.MICROBE_LIFE: 
		{
			&"oxygen": Vector2(0, 400_000),
			&"carbon_dioxide": Vector2(0, 200_000),
			&"methane": Vector2(0, 250_000),
			&"sulfur_dioxide": Vector2(0, 100),
			&"other_toxic_gases": Vector2(0, 500),
			&"ammonia": Vector2(0, 10_000)
		}
}
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
	
func get_symbols() -> Dictionary[StringName, String]:
	return {
		&"oxygen": "O₂",
		&"nitrogen": "N₂",
		&"carbon_dioxide": "CO₂",
		&"sulfur_dioxide": "SO₂",
		&"methane": "CH₄",
		&"argon": "Ar",
		&"hydrogen": "H₂",
		&"helium": "He",
	}
	
func get_elements() -> Dictionary[StringName, float]:
	return {
		&"oxygen": oxygen,
		&"nitrogen": nitrogen,
		&"carbon_dioxide": carbon_dioxide,
		&"sulfur_dioxide": sulfur_dioxide,
		&"methane": methane,
		&"argon": argon,
		&"hydrogen": hydrogen,
		&"helium": helium,
	}
	
func get_custom_colors() -> Array[Color]:
	return GAS_COLORS

func get_habitability_ranges() -> Dictionary[TerraformProperties.TerraformClassification, Dictionary]:
	return HABITABILITY_RANGES
