extends ControlFader

signal grid_cleared

@onready var card_grid: CardGrid = %CardGrid
@onready var interface: = %Interface
@onready var message_display: = %MessageDisplay

@export var opponent_scene : PackedScene
@export var opponent_data : OpponentData
@export var camera : Camera2D

var opponent : Opponent = null
var game_over : bool = false
var is_user_turn : bool = true : set = set_is_user_turn

func _ready() -> void:
	connect_signals()

func start_game() -> void:
	game_over = false
	is_user_turn = true
	#card_grid.set_all_cards_interaction_disabled(false)

func reset_game() -> void:
	GameManager.reset_scores()
	create_opponent_node()
	sync_with_opponent_data()
	card_grid.reset()

func forfeit() -> void:
	end_game(true)

func end_game(user_forfeit: bool = false) -> void:
	print("Game Over")
	card_grid.set_all_cards_interaction_disabled(true) # this changes the zoom
	reset_camera_zoom() # this line resets it as a workaround for now
	grid_cleared.emit(user_forfeit)
	game_over = true
	delete_opponent_node()

func delete_opponent_node() -> void:
	if opponent:
		opponent.queue_free()

## Used to stop processes that would otherwise cause issues if left running [br]
## I'm finding this is a problem with overly relying on awaits lol
func create_opponent_node() -> void:
	var opp = opponent_scene.instantiate()
	opp.card_grid = card_grid
	opp.data = opponent_data
	call_deferred("add_child", opp)
	opponent = opp

func fade_in() -> void:
	visible = true
	await interface.fade_in()
	fade_in_element(self)

func fade_out() -> void:
	if not card_grid.is_empty():
		await card_grid.animate_clear()
	await interface.fade_out()
	await fade_out_element(self).finished
	visible = false

func reset_fade() -> void:
	fade_out_element(self, 0)
	interface.fade_out(true)
	visible = false

func _process(_delta: float) -> void:
	# Update ui transform to nullify camera zoom and displacement
	$UI.offset_transform_scale = Vector2.ONE * 1.0 / camera.zoom
	$UI.offset_transform_position = camera.get_pivot_displacement()

func reset_camera_zoom() -> void:
	camera.target_zoom = 1.0

# SETUP ------------------------------------------------------------------------
func sync_with_opponent_data() -> void:
	opponent.data = opponent_data
	card_grid.columns = opponent_data.grid_dimensions.x
	card_grid.rows = opponent_data.grid_dimensions.y
	interface.sync_opponent_info_with_data(opponent_data)

func connect_signals() -> void:
	card_grid.lockout_changed.connect(_on_card_grid_lockout_changed)
	card_grid.matched_correct.connect(_on_card_grid_matched_correct)
	card_grid.match_finished.connect(_on_card_grid_match_finished)
	card_grid.match_started.connect(_on_card_grid_match_started)


# SCORING HANDLING -------------------------------------------------------------
func increment_relevant_score() -> void:
	if is_user_turn:
		GameManager.user_score += 1
	else:
		GameManager.cpu_score += 1


# TURN HANDLING ----------------------------------------------------------------
## Cycles turns or ends the game if the card grid is empty.
func next_turn() -> void:
	if card_grid.is_empty():
		if not game_over:
			end_game()
	else:
		is_user_turn = not is_user_turn

## Starts the user's turn, enabling field input.
func user_turn_start() -> void:
	await message_display.display_message("YOUR TURN").finished
	interface.field_input_disabled = false

## Starts the opponent's turn if the opponent exists. [br]
## In the case thaat the opponent does not exist, the match has been forfeit and [br]
## the opponent has been deleted to stop any logic.
func opponent_turn_start() -> void:
	await message_display.display_message("OPPONENT TURN").finished
	await get_tree().create_timer(0.3, false).timeout
	if opponent:
		opponent.play()


# SIGNALS ----------------------------------------------------------------------
func _on_card_grid_lockout_changed(lockout_active : bool) -> void:
	var target_zoom = 1.05 if lockout_active else 1.0
	camera.target_zoom = target_zoom

func _on_card_grid_match_started(_correct: bool) -> void:
	interface.field_input_disabled = true

func _on_card_grid_matched_correct() -> void:
	increment_relevant_score()

func _on_card_grid_match_finished(_correct : bool) -> void:
	next_turn()


# SETTERS ----------------------------------------------------------------------
func set_is_user_turn(val) -> void:
	if game_over:
		push_warning("Did not change turn becuase game is concluded")
		return
	
	is_user_turn = val
	interface.highlight_user = is_user_turn
	if is_user_turn:
		await user_turn_start()
	else:
		await opponent_turn_start()
