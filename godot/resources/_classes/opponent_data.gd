class_name OpponentData
extends Resource

@export var display_name : String = ""
@export var portrait : Texture
@export_range(0, 1, 1, "or_greater") var memory_capacity : int
@export_range(0, 1, 1, "or_greater") var memory_lifetime : int
@export_range(0, 1, 0.01) var memory_accuracy : float =1.0

@export_category("Reactions")
@export_subgroup("Swap", "phrase")
@export var phrase_swap_good : String = "Uh oh did you lose something?"
@export var phrase_swap_bad : String = "Now which ones were those..."
@export_subgroup("Hint", "phrase")
@export var phrase_hint_good : String = "No, you can't read my poker face."
@export var phrase_hint_bad : String = "Can I at least have a hint?"
