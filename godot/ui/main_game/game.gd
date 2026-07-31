extends Node2D

@onready var versus_screen = %VersusScreen
@onready var results_screen = %ResultsScreen


func _ready() -> void:
	# setup results screen
	results_screen.rematch_selected.connect(_on_results_screen_rematch_selected)
	results_screen.main_menu_selected.connect(_on_results_main_menu_selected)
	results_screen.reset_fade()
	# setup versus screen
	versus_screen.grid_cleared.connect(_on_versus_screen_grid_cleared)
	versus_screen.reset_game()


# SIGNALS ----------------------------------------------------------------------
func _on_versus_screen_grid_cleared() -> void:
	results_screen.update_results(versus_screen.opponent_data)
	results_screen.content_mode = results_screen.ContentModes.MESSAGE
	results_screen.fade_in()

func _on_results_main_menu_selected() -> void:
	pass

func _on_results_screen_rematch_selected() -> void:
	await results_screen.fade_out()
	versus_screen.reset_game()
