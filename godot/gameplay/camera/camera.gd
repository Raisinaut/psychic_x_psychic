extends Camera2D

@export var can_pivot := true
@export_range (0.0, 0.1, 0.01) var pivot_amount = 0.04
@export_range (0.0, 0.1, 0.005) var pivot_speed = 0.01

@onready var initial_position = global_position

var target_zoom : float = 1.0 : set = set_target_zoom
var zoom_tween : Tween = null

func set_target_zoom(val) -> void:
	target_zoom = val
	tween_zoom(Vector2.ONE * target_zoom, 0.6)

func tween_zoom(value, duration) -> void:
	if zoom_tween : zoom_tween.kill()
	zoom_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	zoom_tween.tween_property(self, "zoom", value, duration)

func _process(_delta: float) -> void:
	var target_pos = initial_position
	if can_pivot:
		target_pos = get_global_mouse_position()
	pivot(target_pos)

func pivot(toward_pos : Vector2):
	var pivot_vector = (initial_position - toward_pos) * pivot_amount
	global_position = lerp(global_position, initial_position - pivot_vector, pivot_speed)
