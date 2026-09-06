extends Resource
class_name PlanetProperties

var name := "Unnamed"
var axial_tilt := 0.0
var orbital_tilt := 0.0
var max_elevation := 0.0
var elevation_map : Texture2D
var map : Texture2D
var representative_color : Color

var _img: Image
var img : Image:
	get:
		if !_img:
			_img = map.get_image()
			_img.decompress()
		return _img

func update_representative_color() -> void: #get the 'color' of this planet by picking random pixels on the map and average it
	const ITERATION = 100
	var average := Color(0, 0, 0)
	for i in ITERATION:
		var x := randi_range(0, img.get_width() - 1)
		var y := randi_range(0, img.get_height() - 1)
		average += img.get_pixel(x, y)
	representative_color = average / ITERATION

func get_elevation(lat_lon: Vector2) -> Color:
	var pos := Game.lat_lon_to_pixel(lat_lon, img.get_size())
	return img.get_pixel(pos.x, pos.y)
