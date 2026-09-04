class_name HSliderExpander
extends HSlider

signal just_expanded
signal just_shrank

@onready var default_length = custom_minimum_size.x

var tween_duration : float = 0.2
var dim_minimum : float = 0.5
var length_tween : Tween
var alpha_tween : Tween
var expanded : bool = false : set = set_expanded
var dragging : bool = false : set = set_dragging
var dimmed : bool = false : set = set_dimmed
var hovered : bool = false

func _ready() -> void:
	reset_shrink()
	connect_signals()

func connect_signals() -> void:
	drag_started.connect(set_dragging.bind(true))
	drag_ended.connect(set_dragging.bind(false).unbind(1))


# EXPAND CONTROL ---------------------------------------------------------------
func expand() -> void:
	just_expanded.emit()
	tween_slider_length(default_length)
	tween_alpha(get_dimmed_alpha())

func shrink() -> void:
	if dragging:
		await drag_ended
	just_shrank.emit()
	tween_slider_length(0)
	tween_alpha(0)

func reset_shrink() -> void:
	custom_minimum_size.x = 0
	modulate.a = 0


# TWEENS -----------------------------------------------------------------------
func tween_slider_length(new_length: float) -> void:
	if length_tween: length_tween.kill()
	length_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	length_tween.tween_property(self, "custom_minimum_size:x", new_length, tween_duration)

func tween_alpha(new_alpha: float) -> void:
	if alpha_tween: alpha_tween.kill()
	alpha_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	alpha_tween.tween_property(self, "modulate:a", new_alpha, tween_duration)


# SETTERS ----------------------------------------------------------------------
func set_dragging(state: bool) -> void:
	dragging = state

func set_expanded(state: bool) -> void:
	expanded = state
	if expanded:
		expand()
	else:
		shrink()

func set_dimmed(state: bool) -> void:
	dimmed = state
	tween_alpha(get_dimmed_alpha())


# UTILITY ----------------------------------------------------------------------
func get_dimmed_alpha() -> float:
	return min(float(!dimmed) + dim_minimum, 1.0)
