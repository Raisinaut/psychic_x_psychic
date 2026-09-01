class_name MusicTrigger
extends Node

@export var music_loop : MusicLoop
@export var play_on_ready : bool = true

func _ready() -> void:
	if play_on_ready and music_loop:
		if MusicManager.get_current_music_loop() != music_loop:
			MusicManager.play_music(music_loop)
