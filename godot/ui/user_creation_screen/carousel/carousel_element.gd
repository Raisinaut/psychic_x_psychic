class_name CarouselElement
extends PanelContainer

var texture: Texture = null : set = set_texture
var pos_offset_tween : Tween = null
var scale_offset_tween : Tween = null
var alpha_tween : Tween = null
var tween_duration: float = 0.25
var tween_ease: Tween.EaseType = Tween.EASE_OUT
var tween_trans: Tween.TransitionType = Tween.TRANS_CUBIC

@onready var texture_rect: TextureRect = %TextureRect


# SETUP-------------------------------------------------------------------------
func _init() -> void:
	offset_transform_enabled = true

func set_texture(new_texture: Texture) -> void:
	if not is_node_ready():
		await ready
	texture = new_texture
	texture_rect.texture = new_texture


# TWEENING ---------------------------------------------------------------------
func tween_offset_position(pos : Vector2, duration: float) -> void:
	if pos_offset_tween: pos_offset_tween.kill()
	pos_offset_tween = create_tween().set_ease(tween_ease).set_trans(tween_trans)
	pos_offset_tween.tween_property(self, "offset_transform_position", pos, duration)

func tween_offset_scale(new_scale : float, duration: float) -> void:
	if scale_offset_tween: scale_offset_tween.kill()
	scale_offset_tween = create_tween().set_ease(tween_ease).set_trans(tween_trans)
	scale_offset_tween.tween_property(self, "offset_transform_scale", Vector2.ONE * new_scale, duration)

func tween_alpha(a : float, duration: float) -> void:
	if alpha_tween: alpha_tween.kill()
	alpha_tween = create_tween().set_ease(tween_ease).set_trans(tween_trans)
	alpha_tween.tween_property(self, "modulate:a", a, duration)
