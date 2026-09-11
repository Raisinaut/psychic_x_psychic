extends Node

@onready var current_camera : CustomCamera

func set_target_zoom_scale(zoom_scale: float) -> void:
	if current_camera:
		current_camera.target_zoom = zoom_scale
	else:
		no_camera_found()

func reset_target_zoom_scale() -> void:
	if current_camera:
		current_camera.target_zoom = 1.0
	else:
		no_camera_found()

func no_camera_found() -> void:
	push_warning("No camera found")
