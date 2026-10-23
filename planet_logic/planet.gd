extends Node3D
class_name Planet
signal city_created(city: City)
@warning_ignore("unused_signal")
signal city_destroyed(city: City)
const OXYGEN_GRADIENT: Gradient = preload("uid://w3mrnkqo8pl2")
@onready var tick_timer : Timer = $TickTimer
var all_event_data: Array[EventData]
var planet_state: PlanetState
var planet_properties : PlanetProperties
var terraform_properties : TerraformProperties = TerraformProperties.new()
var terraform_modifier_per_tick : TerraformProperties = TerraformProperties.new()
var cities : Array[City]
var outposts : Array
var biomass_color: Color = Color.GREEN
@onready var planet_render: PlanetRender = $PlanetRender

var in_creating_city := false

var total_population : int = 0
var total_habitation : int:
	get:
		var total := 0
		for city: City in cities:
			total += city.properties.habitations
		return total
var wait_tasks: Array[WaitTask]
var events_log: Array[Event] #This does NOT include cities log. Only that are truly global

## All gases that exist 
##
##(This will get gases from the directory AND the planet. If planet already have the gas it will not be overriden by the default gas in the directory)
var gases: Dictionary[StringName, Gas]
func append_wait_task(wait_task: WaitTask) -> void:
	wait_tasks.append(wait_task)
	wait_task.completed.connect(erase_wait_task.bind(wait_task))
func erase_wait_task(wait_task: WaitTask) -> void:
	wait_tasks.erase(wait_task)
func _enter_tree() -> void:
	Game.planet = self
func _ready() -> void:
	## TEMPORARY
	planet_properties = preload("uid://dcxijvsc4hv8p") #mars
	planet_render.planet_properties = planet_properties
	planet_render.terraform_properties = terraform_properties
	start()
func _process(_delta: float) -> void:
	if Game.sun.light_energy == 0: planet_render.planet_mat.set_shader_parameter("sun_active", false); return
	if Game.sun.rotate_light:
		planet_render.planet_mat.set_shader_parameter("sun_active", true)
		var sun_dir: Vector3 = Game.sun.global_transform.basis.z
		planet_render.planet_mat.set_shader_parameter("sun_direction", sun_dir)
func _on_update_tick() -> void:
	terraform_properties.add(terraform_modifier_per_tick)
	planet_render.update_appearance()
	var pop: float = 0.0
	for city in cities:
		pop += city.properties.population
	for wait_task in wait_tasks:
		wait_task.checkup()
	total_population = floori(pop)
	var greenhouse_data := _get_greenhouse_and_ppm_sum()
	
	terraform_properties.greenhouse_effect = greenhouse_data[0] * log(1+greenhouse_data[1]) * (terraform_properties.pressure / 100) #simplified from greenhouse_data[0] * log(1+greenhouse_data[1]) * (terraform_properties.pressure / 100_000) * 1000
	random_events()
func _get_greenhouse_and_ppm_sum() -> Array[float]:
	var sum_greenhouse := 0.0
	var sum_ppm := 0.0
	for gas_data: GasData in terraform_properties.atmosphere_composition.get_elements().values():
		sum_greenhouse += gas_data.gas.greenhouse
		sum_ppm += gas_data.ppm
	return [sum_greenhouse, sum_ppm]
func start() -> void: ##Intended for starting a new world. Which expect everything to be empty so it will override some things (which can definetly reset the data so use carefully)
	planet_state = PlanetState.new()
	planet_state.terras = 10_000_000
	##FIX THIS:: vvv 
	@warning_ignore("incompatible_ternary")
	terraform_properties.atmosphere_composition = SimpleAtmosphereComposition.new() if planet_state.terra_mode == PlanetState.TerraMode.SIMPLE else ComplexAtmosphereComposition.new()
	terraform_properties.load_from_starting_terraform_properties(planet_properties.starting_terraform_properties)
	planet_render.terraform_properties = terraform_properties
	planet_render.init_planet_properties()
	for tres_file: String in Game.get_all_tres_files("res://predefined/events/"):
		var new_event_data : EventData = load(tres_file)
		if !is_zero_approx(new_event_data.average_interval_days):
			all_event_data.append(new_event_data)
	
	#Initialize all gases list
	for gas_data: GasData in terraform_properties.atmosphere_composition.get_elements().values():
		if gas_data.gas.is_placeholder:
			continue
		gases[gas_data.gas.name] = gas_data.gas
	
	var gases_dir : Array[String] = Game.get_all_tres_files("res://predefined/gases/")
	for gas_dir in gases_dir:
		var gas : Gas = load(gas_dir)
		if gas.is_placeholder:
			continue
		if !gases.has(gas.name): #DoN'T override if already existed
			gases[gas.name] = gas

func _on_planet_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not in_creating_city and event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var price := 1000000 * (Game.planet.cities.size() + 1)
		if price > planet_state.terras:
			Game.in_game_ui.not_enough_money.notice(price, "build", "city")
			return
		var lat_lon := Game.get_latitude_longitude(to_local(event_position))
		var elevation := planet_properties.get_elevation(lat_lon)
		in_creating_city = true
		var city_name := await Game.in_game_ui.create_new_city_popup.request_create_new_city_name(Vector3(lat_lon.x, lat_lon.y, elevation), price)
		in_creating_city = false
		var new_city := City.new(self, true)
		new_city.name = city_name
		new_city.geoposition = Vector3(lat_lon.x, lat_lon.y, elevation)
		cities.append(new_city)
		planet_render.update_cities_light()
		city_created.emit(new_city)

func random_events(delta_time := 1.0) -> void:
	for event_data: EventData in all_event_data:
		if is_zero_approx(event_data.average_interval_days):
			continue
		
		var probability := 1.0 - exp(-delta_time / event_data.average_interval_days)
		if randf() >= probability:
			continue
			
		var city: City = null
		if !event_data.is_global:
			if cities.is_empty():
				continue
			city = cities.pick_random()
			
		var adj_event_data := event_data.event.duplicate(true)
		var format_args := {
			"planet": planet_properties.name
		}
		if city != null:
			format_args["city"] = city.name
			
		adj_event_data.title = event_data.event.title.format(format_args)
		adj_event_data.description = event_data.event.description.format(format_args)
		
		Game.in_game_ui.event_popup.open_popup_event(adj_event_data)
		
		if city != null:
			city.events_log.append(adj_event_data)
		else:
			events_log.append(adj_event_data)
func fire() -> void:
	pass

func request_recalculation() -> void:
	var new_terraform_modifier_per_tick := TerraformProperties.new()
	for city in cities:
		new_terraform_modifier_per_tick.add(city.terraform_properties_modifier_per_tick)
	terraform_modifier_per_tick = new_terraform_modifier_per_tick
