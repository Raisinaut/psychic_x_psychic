class_name Opponent
extends Node

@export var card_grid : CardGrid

# ATTRIBUTES
var memory_capacity : int = 3
var memory_turn_lifetime: int = 5
var memory_accuracy : float = 1.0

var can_play : bool = false
var card_memory : Dictionary[Card, int] = {}
var selection : Array[Card] = []

func _ready() -> void:
	card_grid.card_flipped.connect(_on_card_grid_card_flipped)

## Plays any found match in order of discovery [br]
## or attempts to make a spontaneous match with [br]
## an already known card and an unknown card.
func play() -> void:
	print("\nOpponent turn started.")
	print_memory_contents()
	if card_grid.active_cards.is_empty():
		print("\tNo cards to choose from")
		return
	# Select Cards
	selection = get_known_match()
	if selection.is_empty():
		print("No match known in memory.")
		# Select an unknown card
		selection.append(select_unknown_card())
		# Check if it matches one in memory
		var memory_match : Card = find_memory_match(selection[0])
		if memory_match:
			print("\tUnknown card matches one in memory.")
			print("\tCard added to selection")
			selection.append(memory_match)
		else:
			print("\tUnknown card doesn't match any in memory.")
			var c : Card = select_unknown_card()
			if c: selection.append(c)
	else:
		print("Match is known in memory.")
	# FLIP CARDS
	if selection:
		for i : Card in selection:
			await i.flip()
			await get_tree().create_timer(0.2).timeout
	else:
		push_error("\tNo cards selected. Make sure memory is accurate.")
	degrade_memory()
	print()


# MEMORY SEARCH ----------------------------------------------------------------
func get_known_match() -> Array[Card]:
	var cards = get_cards_by_least_recent()
	for i in cards:
		for j in cards:
			if i != j:
				if i.data.front == j.data.front:
					return [i, j]
	return []

func get_cards_by_least_recent() -> Array[Card]:
	var cards = card_memory.keys()
	cards.sort_custom(func(a, b): return card_memory[a] < card_memory[b])
	return cards

func get_cards_by_alphabetical() -> Array[Card]:
	var cards = card_memory.keys()
	cards.sort_custom(func(a, b): return a.data.id < b.data.id)
	return cards

func select_unknown_card() -> Card:
	# Duplicate and manipulate array of currently active cards
	var available_cards = card_grid.active_cards.duplicate(true)
	for card in card_memory.keys(): # Disregard known cards
		available_cards.erase(card)
	for card in selection: # Disgregard currently selected cards
		available_cards.erase(card)
	if available_cards.size() == 0:
		push_error("Could not select unkown card. All active cards are known.")
		return null
	print("Unknown card selected.")
	# select randomly from the remaining cards
	available_cards.shuffle()
	return available_cards[0]

func find_memory_match(card : Card) -> Card:
	if card == null: return null
	for i : Card in card_memory.keys():
		if i.data.front == card.data.front:
			return i
	return null

func print_memory_contents() -> void:
	print("Memory Contents:")
	print("".lpad(55, "-"))
	for c : Card in get_cards_by_alphabetical():
		var line : String = "|"
		line += c.data.id.lpad(20) + " | "
		line += str(card_memory[c]) + " turns till forget"
		line += "|".lpad(12)
		print(line)
	print("".lpad(55, "-"))


# MEMORY MODIFICATION ----------------------------------------------------------
func remember_card(card : Card) -> void:
	# Check if already known
	if card_memory.has(card):
		#print("Already known: ", card.data.id, ". Memory lifetime refreshed.")
		pass
	else:
		# Connect match signal
		card.just_matched.connect(_on_card_just_matched.bind(card))
		#print(" + Remembered card: ", card.data.id)
	# Add to memory
	card_memory[card] = memory_turn_lifetime

func forget_card(card : Card) -> void:
	#print(" - Forgot card: ", card.data.id)
	# Remove from memory
	card_memory.erase(card)
	# Disconnect match signal
	card.just_matched.disconnect(_on_card_just_matched)

func forget_least_recent_card() -> void:
	# Only attempt to forget if there is a card to forget lol
	if not card_memory.is_empty():
		forget_card(get_cards_by_least_recent()[0])

func degrade_memory() -> void:
	for c : Card in card_memory:
		card_memory[c] -= 1
		if card_memory[c] <= 0:
			print(c.data.id, " reached memory lifetime end.")
			forget_card(c)


# SIGNALS ----------------------------------------------------------------------
## Flip reaction
func _on_card_grid_card_flipped(card : Card) -> void:
	remember_card(card)
	if card_memory.size() > memory_capacity:
		forget_least_recent_card()

## Match reaction
func _on_card_just_matched(card : Card) -> void:
	print("Card just matched: ", card.data.id)
	forget_card(card)
