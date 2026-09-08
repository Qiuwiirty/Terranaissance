extends Node

var planet: Planet
var sun: Sun
var in_game_ui: InGameUI

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
