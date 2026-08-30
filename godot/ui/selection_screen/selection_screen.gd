extends ControlFader

signal opponent_highlighted(data : OpponentData)
signal opponent_selected(data : OpponentData)

@onready var selection_list: HBoxContainer = %SelectionList

var selected_panel : SelectionPanel = null

func _ready() -> void:
	for i: SelectionPanel in selection_list.get_children():
		i.just_selected.connect(_panel_just_selected.bind(i))
		i.just_highlighted.connect(_panel_just_highlighted.bind(i))

func fade_in() -> void:
	#reset_fade()
	visible = true
	await fade_in_element(self).finished
	# Animate fades
	for i : SelectionPanel in selection_list.get_children():
		i.fade_in()
		await get_tree().create_timer(0.1, false).timeout

func fade_out() -> void:
	var delay_time : float = 0
	var other_panels = selection_list.get_children().duplicate_deep()
	other_panels.erase(selected_panel)
	# Animate panel fades
	for i : SelectionPanel in other_panels:
		delay_time = i.default_fade_time
		i.fade_out()
	await get_tree().create_timer(delay_time, false).timeout
	if selected_panel:
		await selected_panel.fade_out()
	# Fade out rest of screen
	await fade_out_element(self).finished
	visible = false

func reset_fade() -> void:
	visible = false
	modulate.a = 0
	for i : SelectionPanel in selection_list.get_children():
		i.set_disabled(true)
		i.reset_fade()


# SIGNALS ----------------------------------------------------------------------
func _panel_just_selected(panel : SelectionPanel) -> void:
	selected_panel = panel
	opponent_selected.emit(panel.opponent_data)

func _panel_just_highlighted(panel : SelectionPanel) -> void:
	opponent_highlighted.emit(panel.opponent_data)
