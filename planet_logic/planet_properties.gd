extends Resource
class_name PlanetProperties

var axial_tilt := 0.0
var orbital_tilt := 0.0
var max_elevation := 0.0
var elevation_map : Texture2D
var map : Texture2D
var representative_color : Color
func update_representative_color() -> void: #get the 'color' of this planet by picking random pixels on the map and average it
	const ITERATION = 100
	var average := Color(0, 0, 0)
	var image := map.get_image()
	for i in ITERATION:
		var x := randi_range(0, image.get_width() - 1)
		var y := randi_range(0, image.get_height() - 1)
		average += image.get_pixel(x, y)
	representative_color = average / ITERATION
