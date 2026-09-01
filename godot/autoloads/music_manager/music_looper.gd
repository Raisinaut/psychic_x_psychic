class_name MusicLooper
extends AudioStreamPlayer

@export var music_loop : MusicLoop
@export var infinite_loop : bool = true
@export var fade_duration : float = 0.3


var vol_tween : Tween

func _ready() -> void:
	finished.connect(_on_finished)

func restart() -> void:
	stream = music_loop.start
	play()

func _on_finished() -> void:
	match(stream):
		music_loop.start:
			start_section(music_loop.loop)
		music_loop.loop:
			if infinite_loop:
				start_section(music_loop.loop)
			else:
				start_section(music_loop.end)
		music_loop.end:
			pass

func start_section(audio_stream : AudioStream) -> void:
	stream = audio_stream
	play()

func fade_volume_to_linear_value(value : float, duration := fade_duration) -> Tween:
	if vol_tween: vol_tween.kill()
	vol_tween = create_tween()
	vol_tween.tween_property(self, "volume_linear", value, duration)
	return vol_tween

func reset_volume() -> void:
	if vol_tween: vol_tween.kill()
	volume_db = 0
