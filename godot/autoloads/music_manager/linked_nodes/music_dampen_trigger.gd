class_name MusicDampenTrigger
extends Control

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	tree_exiting.connect(_on_tree_exiting)

func _on_visibility_changed() -> void:
	MusicManager.music_dampened = is_visible_in_tree()

func _on_tree_exiting() -> void:
	MusicManager.music_dampened = false # may not be a good idea to set here?
