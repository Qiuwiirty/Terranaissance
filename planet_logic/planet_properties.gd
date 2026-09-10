extends Resource
class_name PlanetProperties
const TEMPERATURE_REQUIREMENT = 287000
const PRESSURE_REQUIREMENT = 100000
const OXYGEN_REQUIREMENT = 210000
@export_category("Essential settings") #basically without these set up your planet won't work
@export var name := "Unnamed"
@export var elevation_map : Texture2D
@export var map : Texture2D
@export var radius := 100.0 #km
@export var max_elevation := 0.0
@export var starting_terraform_properties: TerraformProperties = TerraformProperties.new()
@export_category("Misc settings") #not 100% essential but optional and good to have
@export var axial_tilt := 0.0
@export var orbital_tilt := 0.0

#Variables that can be inferred (define in runtime) and no need to be saved
var representative_color : Color = Color.WHITE #This is for like the gas planet color
var max_biomass := 100000.0 #mt
var _img: Image
@export var img : Image:
	get:
		if !_img:
			_img = map.get_image()
			_img.decompress()
		return _img

#region One time thing you should call when _ready
func init_stuff() -> void:
	update_representative_color()
	update_max_biomass()
func update_representative_color() -> void: #get the 'color' of this planet by picking random pixels on the map and average it
	const ITERATION = 100
	var average := Color(0, 0, 0)
	for i in ITERATION:
		var x := randi_range(0, img.get_width() - 1)
		var y := randi_range(0, img.get_height() - 1)
		average += img.get_pixel(x, y)
	representative_color = average / ITERATION

func update_max_biomass() -> void:
	max_biomass = 0.01 * (4 * PI * radius * radius)

#endregion
func get_elevation(lat_lon: Vector2) -> Color:
	var pos := Game.lat_lon_to_pixel(lat_lon, img.get_size())
	return img.get_pixel(pos.x, pos.y)
