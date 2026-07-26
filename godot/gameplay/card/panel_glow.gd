extends Panel

var flash_tween : Tween = null


func _ready() -> void:
	modulate.a = 0.0

func flash() -> Tween:
	modulate.a = 0.7
	if flash_tween: flash_tween.kill()
	flash_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	flash_tween.tween_property(self, "modulate:a", 0.0, 0.6)
	return flash_tween
