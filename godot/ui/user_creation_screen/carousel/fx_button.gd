class_name FXButton
extends BaseButton

var alpha_tween : Tween

var mouse_in_window : bool = true
var hover_tween_duration: float = 0.1
var pulse_tween_duration: float = 0.2
var default_alpha: float = 0.2
var hover_alpha: float = 0.2
var press_alpha: float = 0.8
var disable_alpha: float = 0.0

var echo_pause_timer: SceneTreeTimer = null
var echoing: bool = false

@export var input_action: String = ""
#@export var allow_echo_inputs: bool = true
@export var echo_pause_duration: float = 0.5


func _ready() -> void:
	mouse_entered.connect(match_hover_state)
	mouse_exited.connect(match_hover_state)
	button_down.connect(pulse)
	button_down.connect(reset_nav_echo)
	reset_alpha()


# INPUT HANDLING ---------------------------------------------------------------
func _process(_delta: float) -> void:
	button_pressed = true
	poll_pressed_state()

func _input(event: InputEvent) -> void:
	if event.is_action(input_action):
		get_viewport().set_input_as_handled()

func poll_pressed_state() -> void:
	if Input.is_action_just_pressed(input_action):
		button_down.emit()
	if Input.is_action_pressed(input_action):
		if echoing and within_echo_pause():
			return
		echoing = true
		pressed.emit()
	else:
		abort_echo_timer()
		echoing = false

func reset_nav_echo() -> void:
	echo_pause_timer = get_tree().create_timer(echo_pause_duration)
	echoing = false

func within_echo_pause() -> bool:
	return echo_pause_timer and echo_pause_timer.time_left > 0

func abort_echo_timer() -> void:
	if echo_pause_timer:
		echo_pause_timer.timeout.emit()
		echo_pause_timer = null


# ANIMATION --------------------------------------------------------------------
func tween_alpha(new_alpha: float, duration: float):
	if alpha_tween: alpha_tween.kill()
	alpha_tween = create_tween().set_ease(Tween.EASE_OUT)
	alpha_tween.tween_property(self, "modulate:a", new_alpha, duration)

func pulse() -> void:
	modulate.a = press_alpha
	tween_alpha(hover_alpha, pulse_tween_duration)

func reset_alpha() -> void:
	modulate.a = default_alpha


# SETTERS ----------------------------------------------------------------------
func match_hover_state() -> void:
	if is_hovered() and mouse_in_window:
		tween_alpha(hover_alpha, hover_tween_duration)
	else:
		tween_alpha(default_alpha, hover_tween_duration)


# CHECKS -----------------------------------------------------------------------
# Tracks mouse focus
func _notification(what: int) -> void:
	match(what):
		NOTIFICATION_WM_MOUSE_ENTER:
			mouse_in_window = true
		NOTIFICATION_WM_MOUSE_EXIT:
			mouse_in_window = false

## Checks if the mouse is hovering over the specified area
func get_mouse_hover_state() -> bool:
	var mouse_pos = get_local_mouse_position()
	return get_rect().has_point(mouse_pos)
