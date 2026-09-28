extends AtmosphereComposition
class_name ComplexAtmosphereComposition
@export var gases: Dictionary[StringName, GasData]

const HABITABILITY_RANGES : Dictionary[TerraformProperties.TerraformClassification, Dictionary] = {
	TerraformProperties.TerraformClassification.PERFECT: 
		{
			&"Oxygen": Vector2(190_000, 220_000),
			&"carbon_dioxide": Vector2(300, 1000),
			&"methane": Vector2(0, 1000),
			&"sulfur_dioxide": Vector2(0, 1),
			&"other_toxic_gases": Vector2(0, 5),
			&"carbon_monoxide": Vector2(0, 10),
			&"ammonia": Vector2(0, 25),
		},
	TerraformProperties.TerraformClassification.HABITABLE: 
		{
			&"Oxygen": Vector2(175_000, 275_000),
			&"methane": Vector2(0, 50_000),
			&"carbon_dioxide": Vector2(200, 10_000),
			&"sulfur_dioxide": Vector2(0, 5),
			&"other_toxic_gases": Vector2(0, 10),
			&"carbon_monoxide": Vector2(0, 35),
			&"ammonia": Vector2(0, 50),
		},
	TerraformProperties.TerraformClassification.PLANT_LIFE: 
		{
			&"Oxygen": Vector2(150_000, 300_000),
			&"carbon_dioxide": Vector2(200, 50_000),
			&"sulfur_dioxide": Vector2(0, 15),
			&"methane": Vector2(0, 50_000),
			&"other_toxic_gases": Vector2(0, 25),
			&"carbon_monoxide": Vector2(0, 20_000),
			&"ammonia": Vector2(0, 500),
		},
	TerraformProperties.TerraformClassification.MICROBE_LIFE: 
		{
			&"Oxygen": Vector2(0, 400_000),
			&"carbon_dioxide": Vector2(0, 200_000),
			&"methane": Vector2(0, 250_000),
			&"sulfur_dioxide": Vector2(0, 100),
			&"other_toxic_gases": Vector2(0, 500),
			&"ammonia": Vector2(0, 10_000)
		}
}
func get_gases_name() -> Array[String]:
	var array: Array[String]
	for gas_data in gases.values:
		array.append(gas_data.gas.name)
	return array
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
	
	for other_gas in get_gases_name():
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
	
	for other_gas in get_gases_name():
		if other_gas == gas:
			continue
			
		set(other_gas, get(other_gas) * scale)
		
	set(gas, new_amount)
func get_atmosphere_color() -> Color:
	var gas_colors: Color = Color.BLACK
	for gas_color in get_custom_colors():
		gas_colors += gas_color
	return gas_colors / 1_000_000
func get_habitability() -> TerraformProperties.TerraformClassification:
	if gases[&"Oxygen"].ppm >= 190000 and gases[&"Oxygen"].ppm <= 220000:
		return TerraformProperties.TerraformClassification.PERFECT
		
	if gases[&"Oxygen"].ppm >= 175000 and gases[&"Oxygen"].ppm <= 275000:
		return TerraformProperties.TerraformClassification.HABITABLE
		
	if gases[&"Oxygen"].ppm >= 150000 and gases[&"Oxygen"].ppm <= 300000:
		return TerraformProperties.TerraformClassification.PLANT_LIFE
		
	if gases[&"Oxygen"].ppm <= 400000:
		return TerraformProperties.TerraformClassification.MICROBE_LIFE
	
	if gases[&"Oxygen"].ppm >= 900000:
		return TerraformProperties.TerraformClassification.HELLISH
	return TerraformProperties.TerraformClassification.BARREN
func add(other: SimpleAtmosphereComposition) -> void:
	gases[&"Oxygen"].ppm += other.oxygen
	
func subtract(other: SimpleAtmosphereComposition) -> void:
	gases[&"Oxygen"].ppm -= other.oxygen
	
func mutiply(other: AtmosphereComposition) -> void:
	gases[&"Oxygen"].ppm *= other.oxygen
	
func mutiply_float(value: float) -> void:
	gases[&"Oxygen"].ppm *= value
	
func add_new_gas(gas_data: GasData) -> void:
	gases.set(gas_data.gas.name, gas_data)
func get_symbols() -> Dictionary[StringName, String]:
	return {
		&"Oxygen": "O₂",
		&"nitrogen": "N₂",
		&"carbon_dioxide": "CO₂",
		&"sulfur_dioxide": "SO₂",
		&"methane": "CH₄",
		&"argon": "Ar",
		&"hydrogen": "H₂",
		&"helium": "He",
	}
	
func get_elements() -> Dictionary[StringName, GasData]:
	return gases
	
func get_custom_colors() -> Array[Color]:
	var colors : Array[Color]
	for gas_data in gases.values():
		colors.append(gas_data.name)
	return colors

func get_habitability_ranges() -> Dictionary[TerraformProperties.TerraformClassification, Dictionary]:
	return HABITABILITY_RANGES
