extends DirectionalLight3D
func _process(delta: float) -> void:
	rotation_degrees.y += delta * 100
