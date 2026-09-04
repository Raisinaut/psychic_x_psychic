extends CanvasLayer

signal opponent_highlighted(data: OpponentData)
signal opponent_selected(data: OpponentData)

@export var versus_screen : PackedScene
@export var results_screen : PackedScene
@export var selection_screen : PackedScene

@onready var pause_screen: = %PauseScreen
@onready var default_screen = selection_screen

var current_screen : Node
var selected_opponent: OpponentData = null

func _ready() -> void:
	open_selection_screen()
	# setup pause screen
	pause_screen.forfeit_selected.connect(_on_pause_screen_forfeit_selected)
	pause_screen.close()
	GameManager.can_pause_changed.connect(pause_screen.set_can_pause)


# SCREEN MANAGEMENT -----------------------------------------------------------
func close_current_screen() -> void:
	if current_screen:
		await current_screen.fade_out()
		current_screen.queue_free()

func open_and_set_current(screen_scene : PackedScene) -> Control:
	var screen_inst = screen_scene.instantiate()
	call_deferred("add_child", screen_inst)
	current_screen = screen_inst
	return current_screen


# OPEN SCREENS -----------------------------------------------------------------
func open_results_screen(data: OpponentData, user_forfeit : bool) -> void:
	GameManager.can_pause = false # not pausable
	var screen = open_and_set_current(results_screen)
	await screen.ready
	screen.update_results(data, user_forfeit)
	screen.content_mode = screen.ContentModes.MESSAGE
	screen.rematch_selected.connect(_on_results_screen_rematch_selected)
	screen.new_opponent_selected.connect(_on_results_new_opponent_selected)
	screen.main_menu_selected.connect(_on_results_main_menu_selected)
	screen.reset_fade()
	screen.fade_in()

func open_selection_screen() -> void:
	GameManager.can_pause = false # not pausable
	var screen = open_and_set_current(selection_screen)
	await screen.ready
	screen.opponent_selected.connect(_on_selection_screen_opponent_selected)
	screen.opponent_highlighted.connect(_on_selection_screen_opponent_highlighted)
	screen.reset_fade()
	screen.fade_in()

func open_versus_screen(data: OpponentData = null) -> void:
	var screen = open_and_set_current(versus_screen)
	if data != null:
		screen.opponent_data = data
	else:
		print("Data reused on versus screen.")
	await screen.ready
	screen.game_just_ended.connect(_on_versus_screen_game_just_ended)
	screen.reset_fade()
	screen.fade_in()
	GameManager.can_pause = true # pausable


# SIGNALS ----------------------------------------------------------------------
# RESULTS
func _on_results_screen_rematch_selected() -> void:
	await close_current_screen()
	open_versus_screen(selected_opponent)

func _on_results_new_opponent_selected() -> void:
	await close_current_screen()
	open_selection_screen()
	
func _on_results_main_menu_selected() -> void:
	# go to main menu
	pass


# SELECTION
func _on_selection_screen_opponent_selected(data : OpponentData) -> void:
	selected_opponent = data
	opponent_selected.emit(data) # update palette data in receiving function
	await close_current_screen()
	open_versus_screen(data)

func _on_selection_screen_opponent_highlighted(data : OpponentData) -> void:
	opponent_highlighted.emit(data)


# VERSUS
func _on_versus_screen_game_just_ended(user_forfeit : bool) -> void:
	GameManager.can_pause = false # disable pausing immediately
	await close_current_screen()
	open_results_screen(selected_opponent, user_forfeit)


# PAUSE
func _on_pause_screen_forfeit_selected() -> void:
	var forfeit_method : String = "forfeit_game"
	if current_screen.has_method(forfeit_method):
		current_screen.forfeit_game() # triggers game_just_ended signal
	else:
		push_error("Current screen does not have method: ", forfeit_method)
