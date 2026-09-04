class_name VolumeControl
extends PanelContainer

signal volume_toggled(toggled: bool)
signal volume_changed(value: float)

@onready var toggle: TextureButton = %Toggle
@onready var slider: HSliderExpander = %Slider

var panel_alpha_tween : Tween = null
var hovered : bool = false : set = set_hovered
var unmuted_value : float = 1.0
var hover_animation_duration : float = 0.15
var min_panel_alpha : float = 0.5

func _ready() -> void:
	connect_signals()
	reset_panel_alpha()
	slider.tween_duration = hover_animation_duration

func connect_signals() -> void:
	toggle.toggled.connect(_on_toggle_toggled)
	slider.value_changed.connect(_on_slider_value_changed)
	slider.just_expanded.connect(_on_slider_just_expanded)
	slider.just_shrank.connect(_on_slider_just_shrank)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func set_slider_value(value: float) -> void:
	slider.value = value

func reset_panel_alpha() -> void:
	self_modulate.a = min_panel_alpha

func unmute() -> void:
	toggle.button_pressed = false


# TWEENS -----------------------------------------------------------------------
func tween_panel_alpha(new_alpha: float) -> void:
	if panel_alpha_tween: panel_alpha_tween.kill()
	panel_alpha_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	panel_alpha_tween.tween_property(self, "self_modulate:a", new_alpha, hover_animation_duration)


# SETTERS ----------------------------------------------------------------------
func set_hovered(state: bool) -> void:
	hovered = state
	slider.expanded = hovered


# SIGNALS ----------------------------------------------------------------------
func _on_toggle_toggled(toggle_state: bool) -> void:
	volume_toggled.emit(toggle_state)
	slider.dimmed = toggle_state

func _on_slider_value_changed(value: float) -> void:
	volume_changed.emit(value)
	unmute()

func _on_slider_just_expanded() -> void:
	tween_panel_alpha(1.0)

func _on_slider_just_shrank() -> void:
	tween_panel_alpha(min_panel_alpha)

func _on_mouse_entered() -> void:
	hovered = true

func _on_mouse_exited() -> void:
	hovered = false
