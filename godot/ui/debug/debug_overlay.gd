extends CanvasLayer

@onready var pause_button: ButtonSlider = %PauseButton
@onready var reset_button: ButtonSlider = %ResetButton
@onready var music_control: ButtonSlider = %MusicControl

func _ready() -> void:
	reset_button.button_pressed.connect(_on_reset_button_pressed)
	pause_button.button_pressed.connect(_on_pause_button_pressed)
	music_control.slider_changed.connect(_on_music_control_slider_changed)
	music_control.button_toggled.connect(_on_music_control_button_toggled)
	music_control.set_slider_value(MusicManager.get_volume_linear())
	GameManager.can_pause_changed.connect(_on_game_manager_can_pause_changed)
	GameManager.can_pause = GameManager.can_pause

func _on_game_manager_can_pause_changed(state: bool) -> void:
	pause_button.visible = state

func _on_music_control_slider_changed(value: float) -> void:
	MusicManager.set_volume_linear(value)

func _on_music_control_button_toggled(state: bool) -> void:
	MusicManager.set_muted(state)

func _on_reset_button_pressed() -> void:
	get_tree().reload_current_scene()

func _on_pause_button_pressed() -> void:
	parse_pause_event()

func parse_pause_event() -> void:
	var pause_event = InputEventAction.new()
	pause_event.action = "pause"
	pause_event.pressed = true
	Input.parse_input_event(pause_event)
