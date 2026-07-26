extends HSlider

signal thumbnail_value_changed(position)

@onready var thumbnail_container : PanelContainer = $ThumbnailContainer
@onready var thumbnail: TextureRect = $ThumbnailContainer/Thumbnail

var is_hovered : bool = false
var is_dragging : bool = false

func _ready() -> void:
	thumbnail.texture = ImageTexture.new()
	thumbnail_container.top_level = true # prevent from affecting hover
	mouse_entered.connect(func(): is_hovered = true)
	mouse_exited.connect(func(): is_hovered = false)
	drag_started.connect(func(): is_dragging = true)
	drag_ended.connect(func(_value): is_dragging = false)

func _process(_delta: float) -> void:
	update_thumbnail_visibility()

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event is InputEventScreenDrag \
			 or InputEventScreenDrag \
			 or InputEventMouseMotion:
		update_thumbnail_position()

func set_thumbnail_image(image : Image) -> void:
	var texture : ImageTexture = thumbnail.texture
	texture.set_image(image)

func update_thumbnail_visibility() -> void:
	thumbnail_container.visible = is_hovered and not is_dragging

func update_thumbnail_position() -> void:
	var hover_pos = get_global_mouse_position()
	var thumbnail_width = thumbnail_container.size.x
	var min_x = 0
	var max_x = get_viewport_rect().size.x - thumbnail_width
	# move thumbnail to nearest position that doesn't cut off the image
	var target_x = hover_pos.x - (thumbnail_width / 2)
	var target_y = global_position.y - thumbnail_container.size.y
	thumbnail_container.global_position.x = clamp(target_x, min_x, max_x)
	thumbnail_container.global_position.y = target_y
	# emit signal containing thumbnail's position along timeline
	var thumbnail_val = get_value_at_position(get_global_mouse_position())
	thumbnail_value_changed.emit(thumbnail_val)

func get_value_at_position(pos : Vector2) -> float:
	var start_pos = global_position
	var end_pos = start_pos + size
	var pos_value = remap(pos.x, start_pos.x, end_pos.x, min_value, max_value)
	return clamp(pos_value, min_value, max_value)
