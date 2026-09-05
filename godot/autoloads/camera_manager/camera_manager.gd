extends Node

@onready var current_camera : CustomCamera

func set_target_zoom_scale(zoom_scale: float) -> void:
	current_camera.target_zoom = zoom_scale

func reset_target_zoom_scale() -> void:
	current_camera.target_zoom = 1.0
