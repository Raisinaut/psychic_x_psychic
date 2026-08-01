class_name PlayerInfo
extends ControlFader

var portrait_texture : Texture = null : set = set_portrait_texture
var name_text : String = "" : set = set_name_text
var score : int = 0 : set = set_score
var darkened : bool = false : set = set_darkened
var darken_tween : Tween = null

@onready var portrait: TextureRect = %Portrait
@onready var noise: TextureRect = %Noise
@onready var name_label: Label = %NameLabel
@onready var score_label: Label = %ScoreLabel
@onready var panel_glow: = $PanelGlow
@onready var panel_darken: Panel = %PanelDarken

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	panel_darken.visible = true # override hide in editor
	noise.visible = true # hidden in editor to avoid rendering shader
	#score = 0
	noise.material.set_shader_parameter("spin_speed", randf_range(0.2, 0.3))

func fade_in(skip_to_end:= false) -> void:
	animation_player.play("fade_in")
	if skip_to_end:
		animation_player.seek(1000, true)
	await get_tree().create_timer(animation_player.current_animation_length).timeout

func fade_out(skip_to_end:= false) -> void:
	animation_player.play("fade_out")
	if skip_to_end:
		animation_player.seek(1000, true)
	await get_tree().create_timer(animation_player.current_animation_length).timeout

# SETTERS ----------------------------------------------------------------------
func set_portrait_texture(val) -> void:
	portrait_texture = val
	portrait.texture = val

func set_name_text(val) -> void:
	name_text = val
	name_label.text = val

func set_score(val) -> void:
	if val > score:
		panel_glow.flash()
	score = val
	score_label.text = str(val)

func set_darkened(val) -> void:
	darkened = val
	tween_darkness(int(darkened))

func tween_darkness(alpha : float) -> void:
	if darken_tween: darken_tween.kill()
	darken_tween = create_tween()
	darken_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	darken_tween.tween_property(panel_darken, "modulate:a", alpha, 0.5)
