extends DirectionalLight3D
class_name Sun
enum StarType {
	O,
	B,
	A,
	F,
	G,
	K,
	M
}
static var sun_to_biomass_colors: Dictionary[StarType, Array] = {
	StarType.O: [Color.WHITE, Color.ANTIQUE_WHITE, Color.CYAN],
	StarType.B: [Color.MISTY_ROSE, Color.PALE_GREEN, Color.BLANCHED_ALMOND],
	StarType.A: [Color.PINK, Color.LIGHT_GREEN, Color.LIGHT_CORAL],
	StarType.F: [Color.MAGENTA, Color.INDIGO, Color.GREEN_YELLOW, Color.GOLD],
	StarType.G: [Color.DEEP_SKY_BLUE, Color.TURQUOISE, Color.GREEN, Color.CORAL, Color.PURPLE, Color.DARK_GREEN],
	StarType.K: [Color.GOLDENROD, Color.RED, Color.NAVY_BLUE, Color.TEAL, Color.WEB_MAROON, Color.SEA_GREEN],
	StarType.M: [Color.DARK_RED, Color.CRIMSON, Color.DARK_BLUE, Color.DARK_SLATE_GRAY, Color.BLACK]
}
@onready var sun_container := get_parent()
@onready var world_environment: WorldEnvironment = %WorldEnvironment
@onready var lens_flare: LensFlareEffect = world_environment.compositor.compositor_effects[0]

@export var rotate_light: bool = true
@export var rotation_speed: float = 10.

@export var star_type : StarType = StarType.G
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
