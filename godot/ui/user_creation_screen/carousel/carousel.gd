extends PanelContainer

const item_separation: float = 400

@export var textures : Array[Texture] = []

@onready var element_container: PanelContainer = %ElementContainer

var index_visibility: int = 2
var current_index: int = 0 : set = set_current_index

func _ready() -> void:
	populate_elements()

func populate_elements() -> void:
	for i in textures.size():
		var element = create_element(textures[i])
		element.offset_transform_position = Vector2(item_separation * i, 0)

func create_element(texture: Texture) -> CarouselElement:
	var element = CarouselElement.new()
	element.texture = texture
	element_container.call_deferred("add_child", element)
	element.ready.connect(update_element.bind(element, false))
	return element

func set_current_index(idx: int) -> void:
	idx = wrapi(idx, 0, textures.size())
	current_index = idx
	print("Carousel index: ", current_index)
	update_all_elements()

func update_all_elements() -> void:
	for i: CarouselElement in element_container.get_children():
		update_element(i, true)

func update_element(element: CarouselElement, tween: bool) -> void:
	var relative_idx: int = element.get_index() - current_index
	var index_limit: int = round(textures.size() / 2.0)
	var wrapped_idx: int = wrapi(relative_idx, -index_limit, index_limit)
	var properties: Array = get_index_properties(wrapped_idx)
	set_element_properties(element, properties, tween)

func set_element_properties(element : CarouselElement, properties : Array, tween: bool) -> void:
	if tween:
		element.tween_offset_position(properties[0])
		element.tween_alpha(properties[1])
		element.tween_offset_scale(properties[2])
	else:
		element.offset_transform_position = properties[0]
		element.modulate.a = properties[1]
		element.offset_transform_scale = Vector2.ONE * properties[2]

func get_index_properties(idx: int) -> Array:
	print(idx)
	var i_position_offset := Vector2(item_separation * idx, 0)
	var i_alpha: float = remap(abs(idx), index_visibility, 0, 0, 1.0)
	var i_scale: float = max(0, remap(abs(idx), 4, 0, 0, 1.0))
	return [i_position_offset, i_alpha, i_scale]

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		current_index -= 1
	if Input.is_action_just_pressed("ui_right"):
		current_index += 1
