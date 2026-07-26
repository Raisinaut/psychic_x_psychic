extends Control

@onready var message_label: Label = %MessageLabel

var fade_time: float = 0.5
var pause_time: float = 1.0
var fade_tween : Tween = null
var fade_duration_timer : SceneTreeTimer = null

var fade_skipped : bool = false

func _ready() -> void:
	modulate.a = 0
	message_label.modulate.a = 0

func display_message(text : String, force_uppercase := false) -> Tween:
	if force_uppercase:
		text = text.to_upper()
	message_label.text = text
	return animate_fade()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and not event.is_echo():
			if is_fading():
				skip_fade()

## Step ahead to the fade out portion of the fade animation
func skip_fade() -> void:
	var total_fade_time = (fade_time * 2) + pause_time
	var fade_out_point = total_fade_time - fade_time
	var fade_progress = total_fade_time - fade_duration_timer.time_left
	var skip_amount = max(0, fade_out_point - fade_progress)
	fade_tween.custom_step(skip_amount)

func animate_fade() -> Tween:
	visible = true
	start_fade_duration_timer()
	if fade_tween: fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.finished.connect(_on_fade_tween_finished)
	# show main control
	fade_tween.tween_property(self, "modulate:a", 1.0, fade_time * 0.5)
	# show text
	fade_tween.tween_property(message_label, "modulate:a", 1.0, fade_time * 0.5)
	# pause
	fade_tween.tween_interval(pause_time)
	# hide text
	fade_tween.tween_property(message_label, "modulate:a", 0.0, fade_time * 0.5)
	# hide main control
	fade_tween.tween_property(self, "modulate:a", 0.0, fade_time * 0.5)
	return fade_tween

func is_fading() -> bool:
	return fade_tween and fade_tween.is_running()

func start_fade_duration_timer() -> void:
	var fade_animation_duration = fade_time * 2 + pause_time
	fade_duration_timer = get_tree().create_timer(fade_animation_duration)


# SIGNALS ----------------------------------------------------------------------
func _on_fade_tween_finished() -> void:
	visible = false
