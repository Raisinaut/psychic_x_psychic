class_name OpponentData
extends Resource

@export var display_name : String = ""
@export var portrait : Texture
@export var palette : Texture
@export_group("Memory", "memory_")
@export_range(0, 1, 1, "or_greater") var memory_capacity : int
@export_range(0, 1, 1, "or_greater") var memory_lifetime : int
@export_group("Accuracy", "accuracy_")
@export_range(0, 1, 0.01) var accuracy_min : float = 1.0
@export_range(0, 1, 0.01) var accuracy_max : float = 1.0

@export_category("Card Info")
@export_range(0, 1, 0.01) var win_rate : float = 1.0
@export var grid_dimensions := Vector2i.ZERO
@export_multiline var description : String = ""

@export_category("Reactions")
@export_subgroup("swap", "phrase")
@export var phrase_swap_good : String = "Uh oh did you lose something?"
@export var phrase_swap_bad : String = "Now which ones were those..."
@export_subgroup("hint", "phrase")
@export var phrase_hint_good : String = "No, you can't read my poker face."
@export var phrase_hint_bad : String = "Can I at least have a hint?"
@export_subgroup("win_state", "phrase")
@export var phrase_win : String = "Better luck in the next life."
@export var phrase_lose : String = "Guess victory wasn't in my cards."
@export var phrase_tie : String = "Most unsatisfying."

func get_description_with_stats() -> String:
	var win_rate_str = str(int(win_rate * 100)) + "%"
	var grid_area_str = str(get_grid_area()) + " Cards"
	var stats_string = "Win Rate: " + win_rate_str + "\n" + \
					   "Grid Area: " + grid_area_str + "\n\n"
	return stats_string + description

func get_grid_area() -> int:
	return grid_dimensions.x * grid_dimensions.y

func get_accuracy_value(rem_lifetime: int) -> float:
	var lifetime_percent: float = rem_lifetime / float(memory_lifetime)
	return lerp(accuracy_min, accuracy_max, lifetime_percent)
