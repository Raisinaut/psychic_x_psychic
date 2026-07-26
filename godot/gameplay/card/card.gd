class_name Card
extends Node2D

signal started_flip
signal ended_flip
signal just_matched

@export var front : Texture : 
	set(val):
		front = val
		hint_texture.texture = front
		if face_up: %Texture.texture = front
@export var back : Texture

var face_up : bool = false : set = set_face_up
var size : Vector2 : set = set_size
var data : CardData = null : set = set_data
var matched : bool = false : 
	set(val): 
		matched = val
		if matched: 
			just_matched.emit()
			set_interaction_disabled(true)
			
# TWEENS
var scale_tween : Tween = null
var mouseover_tween : Tween = null
var shake_tween : Tween = null
var hint_tween : Tween = null

# ANIMATION PROPERTIES
var flip_duration : float = 0.4
var shake_distance : float = 15
var shake_duration : float = 0.25
var hint_duration : float = 2.5

@onready var visuals: Control = %Visuals
@onready var glow = %Glow
@onready var panel: PanelContainer = %Panel
@onready var texture: TextureRect = %Texture
@onready var hint_texture: TextureRect = %HintTexture
@onready var shadow: TextureRect = %Shadow
@onready var press_detection: Button = %PressDetection

# AUDIO
@onready var match_sfx: VariableStreamPlayer2D = %MatchSFX


func _ready() -> void:
	face_up = false
	hint_texture.visible = true
	hint_texture.modulate.a = 0.0
	press_detection.pressed.connect(flip)
	press_detection.mouse_entered.connect(_on_press_detection_mouse_entered)
	press_detection.mouse_exited.connect(_on_press_detection_mouse_exited)

func flip() -> void:
	if animating_flip():
		return
	%FlipSFX.play_random()
	started_flip.emit()
	scale_tween = create_tween().set_trans(Tween.TRANS_SINE)
	scale_tween.set_ease(Tween.EASE_IN)
	scale_tween.tween_property(visuals, "scale:x", 0, flip_duration / 2)
	scale_tween.set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(visuals, "scale:x", 1, flip_duration / 2)
	await scale_tween.step_finished
	face_up = not face_up
	await scale_tween.step_finished
	ended_flip.emit()

func animating_flip() -> bool:
	return scale_tween and scale_tween.is_running()

## Update card size and sync related node sizes.
func set_size(val) -> void:
	panel.size = val
	panel.position = -val * 0.5
	shadow.size = panel.size
	shadow.position = panel.position
	press_detection.size = panel.size
	press_detection.position = panel.position

func get_size() -> Vector2:
	return panel.size

func _on_press_detection_mouse_entered() -> void:
	%HoverSFX.play_random()
	if mouseover_tween: mouseover_tween.kill()
	mouseover_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	mouseover_tween.tween_property(panel, "offset_transform_position:y", -40, 0.15)
	mouseover_tween.parallel().tween_property(panel, "offset_transform_scale", Vector2.ONE * 1.2, 0.15)

func _on_press_detection_mouse_exited() -> void:
	if mouseover_tween: mouseover_tween.kill()
	mouseover_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	mouseover_tween.tween_property(panel, "offset_transform_position:y", 0, 0.15)
	mouseover_tween.parallel().tween_property(panel, "offset_transform_scale", Vector2.ONE, 0.15)


# ANIMATIONS -------------------------------------------------------------------
func shake() -> Tween:
	if shake_tween: shake_tween.kill()
	shake_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	shake_tween.tween_property(visuals, "offset_transform_position:x", shake_distance, shake_duration * 0.15)
	shake_tween.set_ease(Tween.EASE_IN_OUT)
	shake_tween.tween_property(visuals, "offset_transform_position:x", -shake_distance * 0.75, shake_duration * 0.35)
	shake_tween.set_ease(Tween.EASE_OUT)
	shake_tween.tween_property(visuals, "offset_transform_position:x", shake_distance * 0.25, shake_duration * 0.3)
	shake_tween.set_ease(Tween.EASE_IN)
	shake_tween.tween_property(visuals, "offset_transform_position:x", 0, shake_duration * 0.25)
	return shake_tween

func flash() -> Tween:
	return glow.flash()

func hint() -> Tween:
	var max_alpha = 0.7
	var flicker_count : int = 1
	var flicker_duration : float = hint_duration * 0.7 / flicker_count
	var fade_duration : float = hint_duration - flicker_duration
	# reset tween
	if hint_tween: hint_tween.kill()
	hint_tween = create_tween().set_trans(Tween.TRANS_SINE)
	# fade in
	hint_tween.set_ease(Tween.EASE_OUT)
	hint_tween.tween_property(hint_texture, "modulate:a", max_alpha, fade_duration * 0.5)
	# flicker
	hint_tween.set_ease(Tween.EASE_IN_OUT)
	for i in flicker_count:
		var flicker_alpha = max_alpha - 0.2
		hint_tween.tween_property(hint_texture, "modulate:a", flicker_alpha, flicker_duration * 0.25)
		hint_tween.tween_property(hint_texture, "modulate:a", max_alpha, flicker_duration * 0.25)
	# fade out
	hint_tween.set_ease(Tween.EASE_IN)
	hint_tween.tween_property(hint_texture, "modulate:a", 0.0, fade_duration * 0.5)
	return hint_tween

func disappear() -> Tween:
	await %WhirlEffect.grow().finished
	var t = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	t.tween_property(visuals, "scale", Vector2.ZERO, 0.7)
	t.parallel().tween_property(visuals, "rotation", -10, 0.7)
	await get_tree().create_timer(0.5).timeout
	%WhirlEffect.shrink().finished.connect(queue_free)
	return t

func set_interaction_disabled(disabled : bool) -> void:
	if disabled:
		press_detection.mouse_filter = Control.MOUSE_FILTER_IGNORE
		#tween_brightness(0.6)
	else:
		#tween_brightness(1.0)
		press_detection.mouse_filter = Control.MOUSE_FILTER_STOP

func tween_brightness(amount : float) -> void:
	var t = create_tween()
	t.tween_property(self, "modulate", Color(amount, amount, amount), 0.2)


# SETTERS ----------------------------------------------------------------------
func set_face_up(state) -> void:
	face_up = state
	# Show respective side of card
	texture.texture = front if face_up else back
	# disable clicking while face up
	set_interaction_disabled(face_up)

func set_data(val : CardData) -> void:
	if not is_node_ready():
		await ready
	data = val
	front = data.front
