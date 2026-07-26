class_name PlayerInfo
extends PanelContainer

var portrait_texture : Texture = null : set = set_portrait_texture
var name_text : String = "" : set = set_name_text
var score : int = 0 : set = set_score
var darkened : bool = false : set = set_darkened
var darken_tween : Tween = null

@onready var portrait: TextureRect = %Portrait
@onready var portrait_back: TextureRect = %PortraitBack
@onready var name_label: Label = %NameLabel
@onready var score_label: Label = %ScoreLabel
@onready var panel_glow: = $PanelGlow
@onready var panel_darken: Panel = %PanelDarken

func _ready() -> void:
	panel_darken.visible = true # override hide in editor
	portrait_back.visible = true # hidden in editor to avoid rendering shader
	#score = 0
	portrait_back.material.set_shader_parameter("spin_speed", randf_range(0.2, 0.3))

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
