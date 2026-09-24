extends ControlFader

signal forfeit_selected
signal resume_selected

@onready var resume_button: Button = %ResumeButton
@onready var forfeit_button: Button = %ForfeitButton

@onready var button_press_sfx: AudioStreamPlayer = %ButtonPressSFX
@onready var button_hover_sfx: AudioStreamPlayer = %ButtonHoverSFX

var can_pause : bool = false : set = set_can_pause


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(_on_resume_buttton_pressed)
	forfeit_button.pressed.connect(_on_forfeit_button_pressed)
	close()
	connect_button_feedback()

func _input(event: InputEvent) -> void:
	if event.is_action("pause") and can_pause:
		if event.is_pressed() and not event.is_echo():
			if visible:
				close()
			else:
				open()

func open() -> void:
	get_tree().paused = true
	visible = true
	set_buttons_disabled(false)

func close() -> void:
	visible = false
	set_buttons_disabled(true)
	get_tree().paused = false

func set_buttons_disabled(disabled : bool) -> void:
	resume_button.disabled = disabled
	forfeit_button.disabled = disabled

func set_can_pause(state: bool) -> void:
	can_pause = state


# AUDIO FEEDBACK ---------------------------------------------------------------
func connect_button_feedback(node: Node = self, current_depth : int = 0) -> void:
	for i in node.get_children():
		if i is Button:
			i.pressed.connect(play_button_press_sfx)
			i.mouse_entered.connect(play_button_hover_sfx)
		else:
			connect_button_feedback(i, current_depth + 1)

func play_button_press_sfx() -> void:
	button_press_sfx.play()

func play_button_hover_sfx() -> void:
	button_hover_sfx.play()


# SIGNALS ----------------------------------------------------------------------
func _on_resume_buttton_pressed() -> void:
	resume_selected.emit()
	close()

func _on_forfeit_button_pressed() -> void:
	forfeit_selected.emit()
	close()
