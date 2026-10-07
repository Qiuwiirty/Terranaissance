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
static func get_dict_sentence_case(dict: Dictionary) -> Dictionary[String, Variant]:
	var new_dict : Dictionary[String, Variant]
	for key: String in dict.keys():
		new_dict[key.replace("_", " ").capitalize()] = dict[key]
	return new_dict
static func get_modifier_descriptions(fac_transfer: FacilityTransfer, any_gas_name: String) -> String:
	var descriptions: Array[String] = []
	#helper lambda
	var format_stat = func(value: float, stat_name: String, is_per_tick: bool):
		if is_equal_approx(value, 0.0):
			return
		
		var prefix: String = ""
		if value > 0:
			prefix = "++ " if is_per_tick else "+ "
		else:
			prefix = "-- " if is_per_tick else "- "
			
		var value_abs = absf(value)
		var value_str = str(int(value_abs)) if value_abs == int(value_abs) else str(value_abs)
		#Use abs() because nobody obviously gonna want "-- -4 temperature"
		descriptions.append(prefix + value_str + " " + stat_name)
		
	if fac_transfer.terraform_modifier:
		format_stat.call(fac_transfer.terraform_modifier.temperature, "temperature", false)
		format_stat.call(fac_transfer.terraform_modifier.pressure, "pressure", false)
		format_stat.call(fac_transfer.terraform_modifier.water, "water", false)
		format_stat.call(fac_transfer.terraform_modifier.biomass, "biomass", false)
		format_stat.call(fac_transfer.terraform_modifier.revenue, "revenue", false)
		
	if fac_transfer.terraform_modifier_per_tick:
		format_stat.call(fac_transfer.terraform_modifier_per_tick.temperature, "temperature", true)
		format_stat.call(fac_transfer.terraform_modifier_per_tick.pressure, "pressure", true)
		format_stat.call(fac_transfer.terraform_modifier_per_tick.water, "water", true)
		format_stat.call(fac_transfer.terraform_modifier_per_tick.biomass, "biomass", true)
		format_stat.call(fac_transfer.terraform_modifier_per_tick.revenue, "revenue", true)
		
	if fac_transfer.city_modifier:
		format_stat.call(fac_transfer.city_modifier.population, "population", false)
		format_stat.call(fac_transfer.city_modifier.habitations, "habitations", false)
		
	if fac_transfer.city_modifier_per_tick:
		format_stat.call(fac_transfer.city_modifier_per_tick.population, "population", true)
		format_stat.call(fac_transfer.city_modifier_per_tick.habitations, "habitations", true)
		
	if not is_equal_approx(fac_transfer.any_gas_modifier, 0.0):
		format_stat.call(fac_transfer.any_gas_modifier, any_gas_name, true)
		
	return ", ".join(descriptions)
	
static func get_all_tres_files(path: String) -> Array[String]:
	var tres_files: Array[String] = []
	var dir = DirAccess.open(path)
	
	if dir:
		for file in dir.get_files():
			if file.ends_with(".tres") or file.ends_with(".tres.remap"):
				var full_path = path.path_join(file).trim_suffix(".remap")
				tres_files.append(full_path)
		for sub_dir in dir.get_directories():
			var sub_path = path.path_join(sub_dir)
			tres_files.append_array(get_all_tres_files(sub_path))
	else:
		push_error("Uh, this path doesnt exist: ", path)
		
	return tres_files
static func format_time_duration(seconds: int) -> String:
	var days := seconds / 86400
	seconds %= 86400
	
	var hours := seconds / 3600
	seconds %= 3600
	
	var minutes := seconds / 60
	seconds %= 60
	
	var parts: Array[String] = []
	
	if days > 0:
		parts.append(str(days) + "d")
	if hours > 0:
		parts.append(str(hours) + "h")
	if minutes > 0:
		parts.append(str(minutes) + "m")
	if seconds > 0 or parts.is_empty():
		parts.append(str(seconds) + "s")
	
	return " ".join(parts)

static func format_time_timer(seconds: int) -> String:
	var days := seconds / 86400
	seconds %= 86400
	
	var hours := seconds / 3600
	seconds %= 3600
	
	var minutes := seconds / 60
	seconds %= 60
	
	if days > 0:
		return "%dd %02d:%02d:%02d" % [days, hours, minutes, seconds]
		
	return "%02d:%02d:%02d" % [hours, minutes, seconds]
	
##Sometimes planet not available when on main menu or such, so you gotta use this
func get_planet() -> Planet:
	if !planet:
		await planet_available
	return planet
