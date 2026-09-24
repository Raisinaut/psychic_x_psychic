@tool
class_name VariableStreamPlayer
extends AudioStreamPlayer

@export_tool_button("Test") var test_action = test
@export var audio_files : Array[AudioStream] = []
@export_range(0.00, 0.10, 0.01) var pitch_variance = 0.0
@export var base_pitch = 1.0

var rng = RandomNumberGenerator.new()


func _ready():
	rng.randomize()

func play_random():
	randomize_stream()
	play()

func randomize_stream():
	if not audio_files.is_empty():
		var random_index: = rng.randi() % audio_files.size()
		stream = audio_files[random_index]
	pitch_scale = base_pitch + rng.randf_range(-pitch_variance, pitch_variance)

func choose_random_pitch():
	pitch_scale = base_pitch + rng.randf_range(-pitch_variance, pitch_variance)

func test():
	if not Engine.is_editor_hint():
		return
	randomize_stream()
	play()
