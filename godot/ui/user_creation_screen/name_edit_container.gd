extends PanelContainer

@onready var name_edit: LineEdit = %NameEdit
@onready var remaining_characters: Label = %RemainingCharacters

func _ready() -> void:
	name_edit.text_changed.connect(_on_name_edit_text_changed)
	update_remaining_characters()

func _on_name_edit_text_changed(_new_text: String) -> void:
	update_remaining_characters()

func update_remaining_characters() -> void:
	var length = name_edit.text.length()
	var max_length = name_edit.max_length
	remaining_characters.text = str(length) + "/" + str(max_length)
