extends Camera3D
@export_group("Movement")
@export var move_speed: float = 1.
@export var sprint_multiplier: float = 2.

@export_group("Look")
@export var mouse_sensitivity: float = 0.003
@export_range(-89.0, 89.0) var max_pitch_deg: float = 85.0

var _rotation: Vector3 = Vector3.ZERO

func _ready() -> void:
	_rotation = rotation
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_rotation.y -= event.relative.x * mouse_sensitivity
		_rotation.x -= event.relative.y * mouse_sensitivity
		
		var max_pitch_rad := deg_to_rad(max_pitch_deg)
		_rotation.x = clamp(_rotation.x, -max_pitch_rad, max_pitch_rad)
		
		rotation = _rotation

func _process(delta: float) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	# Gather directional movement inputs
	var input_dir := Vector3.ZERO
	if Input.is_key_pressed(KEY_W): input_dir.z -= 1.0
	if Input.is_key_pressed(KEY_S): input_dir.z += 1.0
	if Input.is_key_pressed(KEY_A): input_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D): input_dir.x += 1.0
	if Input.is_key_pressed(KEY_E): input_dir.y += 1.0  # Move Up
	if Input.is_key_pressed(KEY_Q): input_dir.y -= 1.0  # Move Down
	
	input_dir = input_dir.normalized()
	
	var current_speed := move_speed
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed *= sprint_multiplier
		
	var velocity := (global_transform.basis * input_dir) * current_speed * delta
	global_position += velocity
