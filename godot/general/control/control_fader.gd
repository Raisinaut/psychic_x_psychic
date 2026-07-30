class_name ControlFader
extends Control

@export var default_fade_time: float = 0.3

var fade_tween: Tween = null


func fade_in_element(control : Control, duration := default_fade_time) -> Tween:
	control.modulate.a = 0
	if fade_tween: fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(control, "modulate:a", 1.0, duration)
	return fade_tween
	
func fade_out_element(control : Control, duration := default_fade_time) -> Tween:
	#control.modulate.a = 1.0 # not sure if this makes things easier or better
	if fade_tween: fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(control, "modulate:a", 0.0, duration)
	return fade_tween

func is_fading() -> bool:
	return fade_tween and fade_tween.is_running()
