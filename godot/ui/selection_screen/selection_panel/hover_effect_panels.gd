extends PanelContainer

signal fully_expanded
signal fully_retracted

@export var default_rotations_per_second : float = 0.5
@export var clockwise_rotation : bool = true
@export var expand_distance : float = 25
@export var expand_time : float = 0.25

var entity_distance = 0.0 : set = set_entity_distance
var distance_tween : Tween
var rotations_per_second : float = 0.5
var maintain_entity_orientation : bool = true

func _ready() -> void:
	offset_transform_enabled = true
	for i : Control in get_children():
		i.offset_transform_enabled = true
	update_circle_positions()

func _process(delta: float) -> void:
	spin(delta)

func spin(delta : float):
	var speed = (1 / rotations_per_second)
	var rotation_amount = (2 * PI) / speed * delta
	rotation_amount = wrap(rotation_amount, 0, PI * 2)
	if not clockwise_rotation:
		rotation_amount *= -1
	offset_transform_rotation += rotation_amount
	if maintain_entity_orientation:
		for i in get_children():
			i.offset_transform_rotation = -offset_transform_rotation

func flip_rotation_direction() -> void:
	clockwise_rotation = not clockwise_rotation

func reset_rotations_per_second() -> void:
	rotations_per_second = default_rotations_per_second


# ENTITY CONTROL ---------------------------------------------------------------
func update_circle_positions() -> void:
	for i in get_child_count():
		var entity = get_child(i)
		var pos = Vector2.from_angle(get_index_angle(i))
		entity.offset_transform_position = pos

func set_entity_distance(value) -> void:
	entity_distance = value
	for i in get_child_count():
		var entity = get_child(i)
		var pos = Vector2.from_angle(get_index_angle(i)) * entity_distance
		entity.offset_transform_position = pos

func expand_entities() -> void:
	tween_entity_distance(expand_distance).finished.connect(fully_expanded.emit)

func retract_entities() -> void:
	tween_entity_distance(0).finished.connect(fully_retracted.emit)

func tween_entity_distance(to_val : float) -> Tween:
	if distance_tween: distance_tween.kill()
	distance_tween = create_tween()
	distance_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	distance_tween.tween_property(self, "entity_distance", to_val, expand_time)
	return distance_tween


# UTILITY ----------------------------------------------------------------------
func get_index_angle(index : int, max_index = get_child_count()):
	return lerp(0.0, 2 * PI, index / float(max_index))
