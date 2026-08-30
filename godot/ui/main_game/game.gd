extends Node2D

@onready var palette_adapt = %PaletteAdapt
@onready var screen_switcher: = %ScreenSwitcher


func _ready() -> void:
	screen_switcher.opponent_selected.connect(_on_screen_switcher_opponent_selected)
	screen_switcher.opponent_highlighted.connect(_on_screen_switcher_opponent_highlighted)

func _on_screen_switcher_opponent_selected(data : OpponentData) -> void:
	palette_adapt.palette = data.palette

func _on_screen_switcher_opponent_highlighted(data : OpponentData) -> void:
	palette_adapt.palette = data.palette
