extends Node

enum GameResults {
	P1_WIN,
	P2_WIN,
	TIE
}

signal score_changed(id, value)
signal can_pause_changed(state: bool)

var current_opponent_data : OpponentData = null

var can_pause : bool = false: 
	set(state):
		can_pause = state
		can_pause_changed.emit(can_pause)

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

func get_game_results() -> int:
	if user_score > cpu_score:
		return GameResults.P1_WIN
	elif user_score < cpu_score:
		return GameResults.P2_WIN
	else:
		return GameResults.TIE
