class_name CarouselElement
extends PanelContainer

var texture: Texture = null : set = set_texture
var pos_offset_tween : Tween = null
var scale_offset_tween : Tween = null
var alpha_tween : Tween = null

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
func tween_offset_position(pos : Vector2) -> void:
	if pos_offset_tween: pos_offset_tween.kill()
	pos_offset_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	pos_offset_tween.tween_property(self, "offset_transform_position", pos, 0.2)

func tween_offset_scale(new_scale : float) -> void:
	if scale_offset_tween: scale_offset_tween.kill()
	scale_offset_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	scale_offset_tween.tween_property(self, "offset_transform_scale", Vector2.ONE * new_scale, 0.2)

func tween_alpha(a : float) -> void:
	if alpha_tween: alpha_tween.kill()
	alpha_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	alpha_tween.tween_property(self, "modulate:a", a, 0.2)
