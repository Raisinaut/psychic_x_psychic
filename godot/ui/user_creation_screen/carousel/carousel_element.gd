class_name CarouselElement
extends TextureRect

var pos_offset_tween : Tween = null
var scale_offset_tween : Tween = null
var alpha_tween : Tween = null

func _init() -> void:
	offset_transform_enabled = true
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

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
