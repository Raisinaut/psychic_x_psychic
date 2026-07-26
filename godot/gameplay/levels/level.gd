extends Node2D

@onready var card_grid: CardGrid = %CardGrid
@onready var camera: = %Camera
@onready var opponent: Opponent = %Opponent
@onready var interface: = %Interface
@onready var message_display: = %MessageDisplay

@export var is_user_turn : bool = true : set = set_is_user_turn

func _ready() -> void:
	card_grid.lockout_changed.connect(_on_card_grid_lockout_changed)
	card_grid.matched_correct.connect(_on_card_grid_matched_correct)
	card_grid.match_finished.connect(_on_card_grid_match_finished)
	is_user_turn = true
	GameManager.reset_scores()


# SCORING HANDLING -------------------------------------------------------------
func increment_relevant_score() -> void:
	if is_user_turn:
		GameManager.user_score += 1
	else:
		GameManager.cpu_score += 1


# TURN HANDLING ----------------------------------------------------------------
func next_turn() -> void:
	if card_grid.is_empty():
		print("Game Over")
		print()
	is_user_turn = not is_user_turn


# SIGNALS ----------------------------------------------------------------------
func _on_card_grid_lockout_changed(state : bool) -> void:
		camera.target_zoom = 1.05 if state else 1.0

func _on_card_grid_matched_correct() -> void:
	increment_relevant_score()

func _on_card_grid_match_finished(_correct : bool) -> void:
	next_turn()

# SETTERS ----------------------------------------------------------------------
func set_is_user_turn(val) -> void:
	is_user_turn = val
	interface.field_input_disabled = not is_user_turn
	interface.highlight_user = is_user_turn
	# Show Message
	if is_user_turn:
		await message_display.display_message("YOUR TURN").finished
	else:
		await message_display.display_message("OPPONENT TURN").finished
	
	if not is_user_turn:
		await get_tree().create_timer(0.3).timeout
		opponent.play()
