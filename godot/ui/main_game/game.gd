extends Node2D

@onready var palette_adapt = %PaletteAdapt
# Screens
@onready var versus_screen = %VersusScreen
@onready var results_screen = %ResultsScreen
@onready var selection_screen = %SelectionScreen
@onready var pause_screen: = %PauseScreen


func _ready() -> void:
	# setup results screen
	results_screen.rematch_selected.connect(_on_results_screen_rematch_selected)
	results_screen.new_opponent_selected.connect(_on_results_new_opponent_selected)
	results_screen.main_menu_selected.connect(_on_results_main_menu_selected)
	results_screen.reset_fade()
	# setup versus screen
	versus_screen.grid_cleared.connect(_on_versus_screen_grid_cleared)
	versus_screen.reset_fade()
	# setup selection screen
	selection_screen.opponent_selected.connect(_on_selection_screen_opponent_selected)
	selection_screen.opponent_highlighted.connect(_on_selection_screen_opponent_highlighted)
	selection_screen.reset_fade()
	selection_screen.fade_in()
	# setup pause screen
	pause_screen.forfeit_selected.connect(_on_pause_screen_forfeit_selected)
	pause_screen.close()


# SIGNALS ----------------------------------------------------------------------
# VERSUS
func _on_versus_screen_grid_cleared(user_forfeit : bool) -> void:
	pause_screen.can_pause = false
	await versus_screen.fade_out()
	results_screen.update_results(versus_screen.opponent_data, user_forfeit)
	results_screen.content_mode = results_screen.ContentModes.MESSAGE
	results_screen.fade_in()

# RESULTS
func _on_results_screen_rematch_selected() -> void:
	# switch screens
	await results_screen.fade_out()
	versus_screen.reset_game()
	await versus_screen.fade_in()
	versus_screen.start_game()
	# enable pausing
	pause_screen.can_pause = true

func _on_results_new_opponent_selected() -> void:
	await results_screen.fade_out()
	selection_screen.fade_in()
	
func _on_results_main_menu_selected() -> void:
	# go to main menu
	pass

# PAUSE SCREEN
func _on_pause_screen_forfeit_selected() -> void:
	pause_screen.can_pause = false
	versus_screen.forfeit()

# SELECTION
func _on_selection_screen_opponent_selected(data : OpponentData) -> void:
	# update relevant game data
	palette_adapt.palette = data.palette
	versus_screen.opponent_data = data
	versus_screen.reset_game()
	# switch screens
	await selection_screen.fade_out()
	versus_screen.reset_fade()
	versus_screen.fade_in()
	versus_screen.start_game()
	# enable pausing
	pause_screen.can_pause = true

func _on_selection_screen_opponent_highlighted(data : OpponentData) -> void:
	palette_adapt.palette = data.palette
