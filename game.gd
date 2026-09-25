extends Node
signal planet_available

static var planet: Planet
static var current_planet_save: PlanetSave
static var sun: Sun
static var in_game_ui: InGameUI
##set the main planet
func set_planet(new_planet: Planet) -> void:
	planet = new_planet
	planet_available.emit()
static func get_latitude_longitude(pos: Vector3) -> Vector2:
	var dir: Vector3 = pos.normalized()
	var lat_rad: float = asin(dir.y)
	var lon_rad: float = atan2(dir.x, -dir.z)
	
	var latitude_deg: float = rad_to_deg(lat_rad)
	var longitude_deg: float = rad_to_deg(lon_rad)
	
	return Vector2(latitude_deg, longitude_deg)
	
static func lat_lon_to_pixel(lat_lon: Vector2, image_size: Vector2i) -> Vector2i:
	var u := (lat_lon.y + 180.0) / 360.0
	
	var v := (90.0 - lat_lon.x) / 180.0
	
	var pixel_x := clampi(int(u * image_size.x), 0, image_size.x - 1)
	var pixel_y := clampi(int(v * image_size.y), 0, image_size.y - 1)
	
	return Vector2i(pixel_x, pixel_y)

static func lat_lon_to_uv(lat_lon: Vector2) -> Vector2:
	var u: float = (deg_to_rad(lat_lon.y) / (2.0 * PI)) + 0.5
	var v: float = 0.5 - (deg_to_rad(lat_lon.x) / PI)
	return Vector2(u, v)

static func is_in_range(value: float, range_value: Vector2) -> bool:
	return value >= range_value.x and value <= range_value.y
static func humanize_number(number : String) -> String:
	var to_return : String
	var decimals : String
	if "." in number:
		decimals = "." + number.split(".", false, 0)[1]
	if len(number.replace(decimals, "")) < 4:
		return number
	else:
		var i : int = 0
		for item in number.replace(decimals, "").reverse():
			if i == 3:
				item += ","
				i = 0
			to_return = item + to_return
			i += 1
		return to_return + decimals
static func terra_classification_to_string(v: int) -> String:
	return TerraformProperties.TerraformClassification.keys()[v].replace("_", " ")
##Sometimes planet not available when on main menu or such, so you gotta use this
func get_planet() -> Planet:
	if !planet:
		await planet_available
	return planet
