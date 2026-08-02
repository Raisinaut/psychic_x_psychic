class_name SelectionPanel
extends ControlFader

signal just_highlighted
signal just_selected

@onready var button: Button = %Button
@onready var spinning_panels = %SpinningPanels
@onready var portrait: TextureRect = %Portrait
@onready var name_label: Label = %NameLabel
@onready var info_label: Label = %InfoLabel
@onready var info_container: PanelContainer = %InfoContainer
@onready var panel_glow: PanelGlow = %PanelGlow

@onready var info_delay_timer: Timer = %InfoDelayTimer

var disabled : bool = false : set = set_disabled
var highlighted : bool = false : set = set_highlighted
var highlight_lock : bool = false
var show_info_delay : float = 0.4
var raise_height : float = 30
var raise_duration : float = 0.2

var raise_tween : Tween = null
var info_tween : Tween = null

@export var opponent_data : OpponentData = null


func _ready() -> void:
	sync_with_data(opponent_data)
	offset_transform_enabled = true
	tween_info_alpha_to(0, 0)
	# connect signals
	button.mouse_entered.connect(_on_button_mouse_entered)
	button.mouse_exited.connect(_on_button_mouse_exited)
	button.pressed.connect(_on_button_pressed)
	info_delay_timer.timeout.connect(_on_info_delay_timer_timeout)

func sync_with_data(data : OpponentData) -> void:
	if not data:
		push_error("No opponent data to sync with.")
		return
	portrait.texture = data.portrait
	name_label.text = data.display_name
	info_label.text = data.get_description_with_stats()

func select() -> void:
	just_selected.emit()
	highlight_lock = true
	button.disabled = true
	spinning_panels.rotations_per_second *= 4
	hide_info()
	panel_glow.flash()

func start_highlight() -> void:
	just_highlighted.emit()
	spinning_panels.expand_entities()
	raise_to(raise_height)
	info_delay_timer.start(show_info_delay)

func stop_highlight() -> void:
	spinning_panels.retract_entities()
	raise_to(0)
	hide_info()

func show_info() -> void:
	tween_info_alpha_to(1)

func hide_info() -> void:
	tween_info_alpha_to(0)
	info_delay_timer.stop() # prevent timer from going off after hiding

func set_disabled(state : bool) -> void:
	disabled = state
	button.disabled = disabled
	if disabled:
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		button.mouse_filter = Control.MOUSE_FILTER_STOP


# ANIMATION --------------------------------------------------------------------
func raise_to(height : float, duration := raise_duration) -> Tween:
	if raise_tween: raise_tween.kill()
	raise_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	raise_tween.tween_property(self, "offset_transform_position:y", -height, duration)
	return raise_tween

func tween_info_alpha_to(val : float, duration := 0.2) -> Tween:
	if info_tween: info_tween.kill()
	info_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	info_tween.tween_property(info_container, "modulate:a", val, duration)
	return info_tween


# FADING ----------------------------------------------------------------------
func fade_out() -> Tween:
	set_disabled(true)
	await fade_out_element(spinning_panels).finished
	raise_to(-raise_height, 2.0)
	print("fade out")
	return fade_out_element(self)

func fade_in() -> Tween:
	reset_fade()
	raise_to(0, 0.5)
	var tween = fade_in_element(self)
	await tween.finished
	set_disabled(false)
	spinning_panels.modulate.a = 1.0
	return tween

func reset_fade() -> void:
	set_disabled(true)
	self.modulate.a = 0
	spinning_panels.modulate.a = 0
	offset_transform_position.y = raise_height
	highlight_lock = false
	spinning_panels.reset_rotations_per_second()
	spinning_panels.retract_entities()


# SETTERS ----------------------------------------------------------------------
func set_highlighted(val : bool) -> void:
	highlighted = val
	if highlighted:
		start_highlight()
	else:
		if not highlight_lock:
			stop_highlight()


# SIGNALS ----------------------------------------------------------------------
func _on_button_pressed() -> void:
	select()

func _on_button_mouse_entered() -> void:
	highlighted = true

func _on_button_mouse_exited() -> void:
	highlighted = false

func _on_info_delay_timer_timeout() -> void:
	show_info()
