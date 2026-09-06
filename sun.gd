extends DirectionalLight3D
class_name Sun
@onready var world_environment: WorldEnvironment = %WorldEnvironment
@onready var lens_flare: LensFlareEffect = world_environment.compositor.compositor_effects[0]
@export var rotate_light: bool = true
@export var rotation_speed: float = 100.
func _ready() -> void:
	Game.sun = self
func set_sun_visibility(mode: bool) -> void:
	if mode:
		show()
		lens_flare.enabled = true
	else:
		hide()
		lens_flare.enabled = false
func set_sun_color(color: Color) -> void:
	light_color = color
	lens_flare.sun_color = color
func set_sun_intensity(intensity: float) -> void:
	light_energy = intensity
	lens_flare.Effect_Multiplier = 3.593 * intensity
func _process(delta: float) -> void:
	if rotate_light:
		rotation_degrees.y += delta * rotation_speed
