@tool
class_name CardGrid
extends ReferenceRect

signal matched_correct
signal match_started(correct : bool)
signal match_finished(correct : bool)
signal lockout_changed(state: bool)
signal card_flipped(card : Card)

@export_range(0, 1, 1, "or_greater") var columns : int = 4 :
	set(val): columns = val; check_grid_validity()
@export_range(0, 1, 1, "or_greater") var rows : int = 3 :
	set(val): rows = val; check_grid_validity()
@export var spacing : int = 20
@export var card_scene : PackedScene
@export var data_variants : Array[CardData] = []
@export_range(0, 1, 1, "or_greater") var variant_count_override : int = 0

@onready var cards: Node2D = %Cards
@onready var match_sfx: VariableStreamPlayer = %MatchSFX

var variant_count : int = 0
var active_cards : Array[Card] = []
var deck : Array[CardData] = []
#var card_coords : Dictionary[Vector2, Card] = {}
var first_card : Card = null 
var second_card : Card = null

var correct_pause_duation : float = 0.5
var incorrect_pause_duration : float = 0.7
var card_flip_interval : float = 0.2

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	initialize_variant_count()
	#generate_data_variants() # for testing without premade resources
	generate_deck()
	populate()


## SETUP -----------------------------------------------------------------------
func initialize_variant_count() -> void:
	# Default to maximum variants
	var max_variants = round(max_item_count() / 2.0)
	variant_count = max_variants
	# Allow override to anything lower than max
	if variant_count_override in range(1, max_variants):
		variant_count = variant_count_override

func generate_deck() -> void:
	check_grid_validity()
	var pair_count : int = round(max_item_count() / 2.0)
	var data_variants_copy = data_variants.duplicate(true)
	for i in pair_count:
		if data_variants_copy.is_empty():
			data_variants_copy = data_variants.duplicate(true)
		data_variants_copy.shuffle()
		var data = data_variants_copy.pop_back()
		# create a pair
		deck.append(data)
		deck.append(data)

func populate() -> void:
	var card_spacing = Vector2.ONE * spacing
	var card_area : Vector2 = size / Vector2(columns, rows)
	var max_card_size = card_area - card_spacing
	var card_center_offset = card_area * 0.5
	for x in columns:
		for y in rows:
			var c = create_card(draw_shuffled_card_data())
			var coords = Vector2(x, y)
			#card_coords[coords] = c
			c.global_position = card_area * coords + card_center_offset
			c.ready.connect(maximize_card_size.bind(c, max_card_size))
			c.started_flip.connect(_on_card_started_flip.bind(c))
			c.just_matched.connect(active_cards.erase.bind(c))
			active_cards.append(c)

## Returns CardData from a shuffled deck and removes it from the pool
## If drawing is attempted on a depleted deck, the deck is refreshed
func draw_shuffled_card_data() -> CardData:
	deck.shuffle()
	return deck.pop_back()

func create_card(data : CardData) -> Card:
	var card = card_scene.instantiate()
	cards.call_deferred("add_child", card)
	card.data = data
	return card

func maximize_card_size(card : Card, max_size : Vector2) -> void:
	card.set_size(fit_vector_proportinally(card.get_size(), max_size))

func fit_vector_proportinally(original: Vector2, target: Vector2) -> Vector2:
	var change_percent : float = 0
	var x_change_percent = target.x / original.x
	var y_change_percent = target.y / original.y
	if x_change_percent < y_change_percent:
		change_percent = x_change_percent
	else:
		change_percent = y_change_percent
	return original * change_percent


# MATCH HANDLING ---------------------------------------------------------------
func attempt_match(card1 : Card, card2 : Card) -> void:
	set_all_cards_interaction_disabled(true)
	var correct : bool = card1.data.front == card2.data.front
	match_started.emit(correct)
	if correct:
		await get_tree().create_timer(correct_pause_duation).timeout
		#correct_match()
		match_sfx.play_random()
		await correct_match()
	else:
		await get_tree().create_timer(incorrect_pause_duration).timeout
		#incorrect_match()
		await incorrect_match()
	match_finished.emit(correct)
	set_all_cards_interaction_disabled(false)

func correct_match() -> void:
	var card_reference = first_card
	# set to matched
	first_card.matched = true
	second_card.matched = true
	# flash 
	first_card.flash()
	second_card.flash()
	matched_correct.emit()
	# delete
	first_card.disappear()
	await second_card.disappear()
	# perform action
	var action_tween = attempt_action(card_reference.data.action_name)
	if action_tween:
		await action_tween.finished
	# reset
	first_card = null
	second_card = null

func incorrect_match() -> void:
	# reset cards
	var _first_card = first_card
	var _second_card = second_card
	first_card = null
	second_card = null
	# animate
	_first_card.shake()
	await _second_card.shake().finished
	await get_tree().create_timer(0.5).timeout
	# flip back over
	_first_card.flip()
	await get_tree().create_timer(card_flip_interval).timeout
	_second_card.flip()
	await _second_card.ended_flip

func attempt_action(action : String) -> Tween:
	if card_actions.keys().has(action):
		return call(card_actions[action])
	else:
		return null

func _on_card_started_flip(card: Card) -> void:
	if card.face_up: return
	# only consider cards that are flipping toward face up,
	# not cards that are starting to flip while already facing up
	if !first_card:
		first_card = card
	elif !second_card:
		second_card = card
		attempt_match(first_card, second_card)
	card_flipped.emit(card)

func set_all_cards_interaction_disabled(state : bool) -> void:
	lockout_changed.emit(state)
	for i in cards.get_children():
		i.set_interaction_disabled(state)


# CARD ACTIONS -----------------------------------------------------------------
var card_actions : Dictionary[String, String] = {
	"swap" : "swap_random_card_positions",
	"hint" : "hint_random_card"
}

# SWAP
func swap_random_card_positions() -> Tween:
	if active_cards.size() < 2:
		push_warning("Swap aborted. Requires 2 or more cards on the field")
		return null
	active_cards.shuffle()
	return swap_card_positions(active_cards[0], active_cards[1])

func swap_card_positions(card1 : Card, card2 : Card) -> Tween:
	tween_node_position(card1, card2.global_position)
	return tween_node_position(card2, card1.global_position)

func tween_node_position(node : Node2D, end_position : Vector2) -> Tween:
	var t = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(node, "global_position", end_position, 0.6)
	return t

# HINT
func hint_random_card() -> Tween:
	if active_cards.size() < 1:
		print("Hint aborted. Requires at least one card on the field.")
		return null
	active_cards.shuffle()
	return hint_card(active_cards[0])

func hint_card(card : Card) -> Tween:
	return card.hint()



# UTILITY ----------------------------------------------------------------------
func check_grid_validity() -> void:
	if not is_node_ready():
		await ready
	if max_item_count() % 2 != 0:
		push_warning("Grid should have an even number of items.")

func max_item_count() -> int:
	return columns * rows

func get_random_cards(qty: int) -> Array[Card]:
	var card_array : Array[Card] = []
	if qty > active_cards.size():
		push_error("Not enough active cards to retrieve a quantity of ", qty)
	else:
		active_cards.shuffle()
		for i in qty:
			card_array.append(active_cards[i])
	return card_array

func is_empty() -> bool:
	return active_cards.is_empty()
