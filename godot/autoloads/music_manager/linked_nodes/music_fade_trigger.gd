class_name MusicFadeTrigger
extends Node

@export var fade_in : bool = false

func _ready() -> void:
	MusicManager.fade_out()
	print("Fade")
