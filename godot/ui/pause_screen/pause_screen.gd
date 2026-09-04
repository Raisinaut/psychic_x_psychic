extends ControlFader

signal forfeit_selected
signal resume_selected

@onready var resume_button: Button = %ResumeButton
@onready var forfeit_button: Button = %ForfeitButton

var can_pause : bool = false : set = set_can_pause

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(_on_resume_buttton_pressed)
	forfeit_button.pressed.connect(_on_forfeit_button_pressed)
	close()

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


# SIGNALS ----------------------------------------------------------------------
func _on_resume_buttton_pressed() -> void:
	resume_selected.emit()
	close()

func _on_forfeit_button_pressed() -> void:
	forfeit_selected.emit()
	close()
