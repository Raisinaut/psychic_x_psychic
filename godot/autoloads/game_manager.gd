extends Node

signal score_changed(id, value)

var user_score : int = 0:
	set(val):
		user_score = val
		score_changed.emit("user", val)
var cpu_score : int = 0:
	set(val):
		cpu_score = val
		score_changed.emit("cpu", val)

func reset_scores() -> void:
	user_score = 0
	cpu_score = 0
