class_name MusicDampenTrigger
extends Control

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	MusicManager.music_dampened = is_visible_in_tree()
