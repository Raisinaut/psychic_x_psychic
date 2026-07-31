extends Sprite2D

var scale_tween : Tween = null

func grow() -> Tween:
	if scale_tween: scale_tween.kill()
	scale_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	scale_tween.tween_property(self, "scale", Vector2.ONE * 0.3, 0.3)
	return scale_tween

func shrink() -> Tween:
	if scale_tween: scale_tween.kill()
	scale_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	scale_tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	return scale_tween

func _process(delta) -> void:
	rotation -= 10 * delta
