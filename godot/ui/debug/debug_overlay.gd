extends CanvasLayer

@onready var reset_button: Button = %ResetButton
@onready var volume_button: TextureButton = %VolumeButton


func _ready() -> void:
	reset_button.pressed.connect(_on_reset_button_pressed)
	volume_button.toggled.connect(_on_volume_button_toggled)

func _on_reset_button_pressed() -> void:
	get_tree().reload_current_scene()

func _on_volume_button_toggled(state: bool) -> void:
	MusicManager.mute_music(state)
