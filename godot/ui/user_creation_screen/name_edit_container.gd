extends PanelContainer

@onready var name_edit: LineEdit = %NameEdit
@onready var remaining_characters: Label = %RemainingCharacters

func _ready() -> void:
	name_edit.text_changed.connect(_on_name_edit_text_changed)
	name_edit.focus_entered.connect(_on_name_edit_focus_entered)
	name_edit.focus_exited.connect(_on_name_edit_focus_exited)
	update_remaining_characters()
	remaining_characters.hide()

func update_remaining_characters() -> void:
	var length = name_edit.text.length()
	var max_length = name_edit.max_length
	remaining_characters.text = str(length) + "/" + str(max_length)


# SIGNALS ----------------------------------------------------------------------
func _on_name_edit_text_changed(_new_text: String) -> void:
	update_remaining_characters()
	# Absorb actions that overlap with characters
	if Input.is_action_just_pressed("toggle_overlay"):
		get_viewport().set_input_as_handled()

func _on_name_edit_focus_entered() -> void:
	remaining_characters.show()
	
func _on_name_edit_focus_exited() -> void:
	remaining_characters.hide()
