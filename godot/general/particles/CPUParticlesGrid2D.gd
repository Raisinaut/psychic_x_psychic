@tool
class_name CPUParticlesGrid2D
extends CPUParticles2D

@export_category("Emission Point Generation")
@export var generate : bool = false : set = _set_generate
@export var area_extents = Vector2(16, 16)
@export var point_spacing : int = 8 #in pixels


func _ready() -> void:
	emission_shape = CPUParticles2D.EMISSION_SHAPE_POINTS


func _set_generate(_state):
	generate = false
	update_shape_points()


func update_shape_points():
	var points : PackedVector2Array = []
	var top_left = Vector2.ZERO - area_extents
	var shape_size = area_extents * 2
	
	var x = 0
	var y = 0
	while x <= shape_size.x:
		while y <= shape_size.y:
			var new_point = top_left + Vector2(x, y)
			points.append(new_point)
			y += point_spacing
		x += point_spacing
		y = 0
	
	emission_shape = CPUParticles2D.EMISSION_SHAPE_POINTS
	emission_points = points
