extends Node2D

signal grid_cleared

@onready var card_grid: CardGrid = %CardGrid
@onready var opponent: Opponent = %Opponent
@onready var interface: = %Interface
@onready var message_display: = %MessageDisplay

@export var opponent_data : OpponentData
@export var camera : Camera2D

var is_user_turn : bool = true : set = set_is_user_turn

func _ready() -> void:
	connect_signals()

func reset_game() -> void:
	sync_with_opponent_data()
	GameManager.reset_scores()
	interface.fade_out(true)
	interface.fade_in()
	is_user_turn = true
	card_grid.reset()

func end_game() -> void:
	print("Game Over")
	interface.fade_out()
	await get_tree().create_timer(0.5).timeout
	grid_cleared.emit()

func _process(_delta: float) -> void:
	# Update ui transform to nullify camera zoom and displacement
	$UI.offset_transform_scale = Vector2.ONE * 1.0 / camera.zoom
	$UI.offset_transform_position = camera.get_pivot_displacement()


# SETUP ------------------------------------------------------------------------
func sync_with_opponent_data() -> void:
	opponent.data = opponent_data
	interface.sync_opponent_info_with_data(opponent_data)

func connect_signals() -> void:
	card_grid.lockout_changed.connect(_on_card_grid_lockout_changed)
	card_grid.matched_correct.connect(_on_card_grid_matched_correct)
	card_grid.match_finished.connect(_on_card_grid_match_finished)


# SCORING HANDLING -------------------------------------------------------------
func increment_relevant_score() -> void:
	if is_user_turn:
		GameManager.user_score += 1
	else:
		GameManager.cpu_score += 1


# TURN HANDLING ----------------------------------------------------------------
func next_turn() -> void:
	if card_grid.is_empty():
		end_game()
	else:
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
