extends Node

@onready var music_player: MusicLooper = %MusicPlayer

var music_dampened : bool = false : set = set_music_dampened
var muted : bool = false : set = set_muted
var mute_toggle_duration : float = 0.005

#func _ready() -> void:
	#connect_web_signals() # May not be required with new implementation

func connect_web_signals() -> void:
	if OS.has_feature("web"):
		# Mute when unfocused
		get_window().focus_entered.connect(func(): music_player.stream_paused = false)
		get_window().focus_exited.connect(func(): music_player.stream_paused = false)


# PLAYBACK CONTROL -------------------------------------------------------------
func play_music(music_loop : MusicLoop) -> void:
	music_player.reset_volume()
	music_player.music_loop = music_loop
	music_player.restart()


# MASTER VOLUME CONTROL --------------------------------------------------------
func set_volume_linear(value: float) -> void:
		AudioServer.set_bus_volume_linear(get_music_bus_idx(), value)

func set_muted(state : bool) -> void:
	muted = state
	if muted:
		fade_out(mute_toggle_duration)
	else:
		fade_in(mute_toggle_duration)


# PLAYER VOLUME CONTROL --------------------------------------------------------
func fade_out(duration := 0.3) -> void:
	music_player.fade_volume_to_linear_value(0.0, duration)

func fade_in(duration := 0.3) -> void:
	music_player.fade_volume_to_linear_value(1.0, duration)


# SETTERS ----------------------------------------------------------------------
func set_music_dampened(state : bool) -> void:
	music_dampened = state
	_set_music_lowpass_enabled(music_dampened)

func _set_music_lowpass_enabled(enabled : bool) -> void:
	var music_bus_idx = AudioServer.get_bus_index("Music")
	var effect_idx : int = 0
	AudioServer.set_bus_effect_enabled(music_bus_idx, effect_idx, enabled)


# GETTERS ----------------------------------------------------------------------
func get_volume_linear() -> float:
	return AudioServer.get_bus_volume_linear(get_music_bus_idx())


# UTILITY ----------------------------------------------------------------------
func get_current_music_loop() -> MusicLoop:
	return music_player.music_loop

func get_music_bus_idx() -> int:
	return AudioServer.get_bus_index("Music")
