@tool
class_name ButtonSlider
extends PanelContainer

signal button_pressed
signal button_toggled(toggled: bool)
signal slider_changed(value: float)

@export var label_text : String = "Volume" : set = set_label_text
@export var button_toggle_mode : bool = false : set = set_button_toggle_mode
@export_group("Button Textures", "button_texture_")
@export var button_texture_normal : Texture = null : set = set_button_texture_normal
@export var button_texture_pressed : Texture = null : set = set_button_texture_pressed
@export_group("Element Visibility", "show_")
@export var show_label : bool = true : set = set_show_label
@export var show_button : bool = true : set = set_show_button
@export var show_slider : bool = true : set = set_show_slider

@onready var button: TextureButton = %Button
@onready var slider: HSliderExpander = %Slider

var panel_alpha_tween : Tween = null
var hovered : bool = false : set = set_hovered
var hover_animation_duration : float = 0.15
var min_panel_alpha : float = 0.5

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	connect_signals()
	reset_panel_alpha()
	slider.tween_duration = hover_animation_duration

func connect_signals() -> void:
	button.toggled.connect(_on_button_toggled)
	button.pressed.connect(_on_button_pressed)
	slider.value_changed.connect(_on_slider_value_changed)
	slider.just_expanded.connect(_on_slider_just_expanded)
	slider.just_shrank.connect(_on_slider_just_shrank)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func set_slider_value(value: float) -> void:
	slider.value = value

func reset_panel_alpha() -> void:
	self_modulate.a = min_panel_alpha

func unpress_button() -> void:
	if button.toggle_mode == true:
		button.button_pressed = false


# TWEENS -----------------------------------------------------------------------
func tween_panel_alpha(new_alpha: float) -> void:
	if panel_alpha_tween: panel_alpha_tween.kill()
	panel_alpha_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	panel_alpha_tween.tween_property(self, "self_modulate:a", new_alpha, hover_animation_duration)


# SETTERS ----------------------------------------------------------------------
func set_hovered(state: bool) -> void:
	hovered = state
	slider.expanded = hovered

func set_label_text(text: String) -> void:
	label_text = text
	%Label.text = label_text

func set_show_label(state: bool) -> void:
	show_label = state
	%Label.visible = show_label

func set_show_button(state: bool) -> void:
	show_button = state
	%Button.visible = show_button

func set_show_slider(state: bool) -> void:
	show_slider = state
	%Slider.visible = show_slider

func set_button_toggle_mode(state: bool) -> void:
	button_toggle_mode = state
	%Button.toggle_mode = button_toggle_mode

func set_button_texture_normal(texture: Texture) -> void:
	button_texture_normal = texture
	%Button.texture_normal = button_texture_normal

func set_button_texture_pressed(texture: Texture) -> void:
	button_texture_pressed = texture
	%Button.texture_pressed = button_texture_pressed


# SIGNALS ----------------------------------------------------------------------
func _on_button_toggled(toggle_state: bool) -> void:
	button_toggled.emit(toggle_state)
	slider.dimmed = toggle_state

func _on_button_pressed() -> void:
	button_pressed.emit()

func _on_slider_value_changed(value: float) -> void:
	slider_changed.emit(value)
	unpress_button()

func _on_slider_just_expanded() -> void:
	tween_panel_alpha(1.0)

func _on_slider_just_shrank() -> void:
	tween_panel_alpha(min_panel_alpha)

func _on_mouse_entered() -> void:
	hovered = true

func _on_mouse_exited() -> void:
	hovered = false
