@tool
class_name AtlasTextureRect
extends TextureRect

@export var index : int = 0 : set = set_index
@export var cols : int = 1
@export var rows : int = 1

func set_index(val) -> void:
	val = clamp(val, 0, max_index())
	index = val
	var col = index % cols
	var row = (index - col) % rows
	var idx_coords := Vector2(col, row)
	if not is_node_ready():
		await ready
	texture.region.position = get_cell_size() * idx_coords

func get_cell_size() -> Vector2:
	return texture.region.size

func max_index() -> int:
	return cols * rows - 1
