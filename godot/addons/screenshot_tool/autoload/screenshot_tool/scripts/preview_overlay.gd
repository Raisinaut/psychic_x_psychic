extends CanvasLayer

signal screenshot_confirmed
signal screenshot_canceled
signal timeline_percent_changed(percent)
signal timeline_thumbnail_value_changed

@onready var preview : TextureRect = $Control/Preview
@onready var flash : ColorRect = $Control/Flash
@onready var confirmation := %ConfirmationDialog
@onready var shadow = $Control/Shadow
@onready var timeline: HSlider = %Timeline

var flash_tween : Tween = null


func _ready() -> void:
	close()
	preview.texture = ImageTexture.new()
	confirmation.confirmed.connect(_on_confirmed)
	confirmation.canceled.connect(_on_canceled)
	confirmation.close_requested.connect(_on_canceled)
	timeline.value_changed.connect(_on_timeline_value_changed)
	timeline.thumbnail_value_changed.connect(_on_thumbnail_value_changed)

func start_flash(duration := 0.5):
	flash.color.a = 0.5
	
	if flash_tween:
		flash_tween.kill()
	flash_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	flash_tween.tween_property(flash, "color:a", 0.0, duration)

func open():
	timeline.value = timeline.max_value
	start_flash()
	confirmation.show()
	shadow.show()
	show()

func close():
	confirmation.hide()
	shadow.hide()
	hide()

func set_preview_image(image : Image) -> void:
	var texture : ImageTexture = preview.texture
	texture.set_image(image)

func set_timeline_steps(step_count : int) -> void:
	step_count = max(0, step_count)
	timeline.step = timeline.max_value / step_count


# SIGNALS ----------------------------------------------------------------------
func _on_confirmed():
	screenshot_confirmed.emit()
	close()

func _on_canceled():
	screenshot_canceled.emit()
	close()

func _on_timeline_value_changed(value : float) -> void:
	var new_percentage = value / timeline.max_value
	timeline_percent_changed.emit(new_percentage)

func _on_thumbnail_value_changed(value : float) -> void:
	timeline_thumbnail_value_changed.emit(value)
