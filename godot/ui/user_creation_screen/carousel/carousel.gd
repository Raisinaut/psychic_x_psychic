class_name Carousel
extends PanelContainer

signal all_elements_ready

const item_separation: float = 400

@export var textures : Array[Texture] = []

@onready var element_container: PanelContainer = %ElementContainer

var index_visibility: int = 3
var end_buffer_count : int = 0 # blank indices that can delineate the loop point
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
	element.ready.connect(_on_element_ready.bind(element))
	return element

func set_current_index(idx: int) -> void:
	idx = wrapi(idx, 0, textures.size())
	current_index = idx
	update_all_elements()

func update_all_elements() -> void:
	for i: CarouselElement in element_container.get_children():
		update_element(i, true)

func update_element(element: CarouselElement, tween: bool) -> void:
	var relative_idx: int = element.get_index() - current_index
	var index_max: int = round(textures.size() / 2.0)
	var index_min: int = -index_max - end_buffer_count # include buffer on end
	if textures.size() % 2 == 1:
		index_min += 1 # Add 1 to account for division of odd pool size
	var wrapped_idx: int = wrapi(relative_idx, index_min, index_max)
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
	var i_position_offset := Vector2(item_separation * idx, 0)
	var i_alpha: float = remap(abs(idx), index_visibility, 0, 0, 1.0)
	var i_scale: float = max(0, remap(abs(idx), 4, 0, 0, 1.0))
	return [i_position_offset, i_alpha, i_scale]

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		current_index -= 1
	if Input.is_action_just_pressed("ui_right"):
		current_index += 1

func _on_element_ready(element: CarouselElement) -> void:
	update_element(element, false)
	if element.get_index() == textures.size() - 1:
		all_elements_ready.emit()

func get_current_element() -> CarouselElement:
	return element_container.get_child(current_index)

func find_element_with_texture(t: Texture) -> CarouselElement:
	for e: CarouselElement in element_container.get_children():
		if e.texture == t:
			return e
	return null

func go_to_element(element: CarouselElement) -> void:
	current_index = element.get_index()

func go_to_element_with_texture(t: Texture) -> void:
	if t == null:
		return
	var element = find_element_with_texture(t)
	if element == null:
		return
	go_to_element(element)
