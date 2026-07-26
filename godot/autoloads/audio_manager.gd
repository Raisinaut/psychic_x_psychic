extends Node

@export var main_music : AudioStream

@onready var music_bus_index =  AudioServer.get_bus_index("Music")
@onready var current_player: AudioStreamPlayer = %CurrentPlayer

var volume_tween : Tween = null

func _ready() -> void:
	current_player.stream = main_music
	current_player.play()

func fade_music_to_db(db : float, duration : float) -> void:
	if volume_tween: volume_tween.kill()
	volume_tween = create_tween()
	volume_tween.tween_method(set_music_bus_volume, get_music_bus_volume(), db, duration)

func mute_music(state: bool) -> void:
	#AudioServer.set_bus_mute(music_bus_index, state)
	if state:
		fade_music_to_db(-60, 0.1)
	else:
		fade_music_to_db(0, 0.1)

func set_music_bus_volume(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_index, value)

func get_music_bus_volume() -> float:
	return AudioServer.get_bus_volume_db(music_bus_index)
