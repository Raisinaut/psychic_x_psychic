class_name Opponent
extends Node

@export var card_grid : CardGrid
@export var print_logic : bool = true

var data : OpponentData = null

var can_play : bool = false
var card_memory : Dictionary[Card, int] = {}
var selection : Array[Card] = []

func _ready() -> void:
	card_grid.card_flipped.connect(_on_card_grid_card_flipped)

## Plays any found match in order of discovery
## or attempts to make a spontaneous match with
## an already known card and an unknown card. [br]
## Can make "mistakes" if accuracy is set lower than 1.0
func play() -> void:
	logic_print("\n-- Opponent turn started")
	_print_memory_contents()
	if card_grid.is_empty():
		logic_print("No cards to choose from.")
		return
	logic_print("-- Selecting cards")
	selection = get_known_match()
	if selection.is_empty():
		logic_print("No match known in memory.")
		selection.append(select_random_card(true))
		var memory_match : Card = find_memory_match(selection[0])
		if memory_match:
			logic_print("Unknown card matches one in memory.")
			logic_print("Matching card added to selection.")
			selection.append(memory_match)
		else:
			logic_print("Unknown card doesn't match any in memory.")
			var c : Card = select_random_card(true)
			if c: selection.append(c)
	else:
		logic_print("Match is known in memory: " + str(selection[0].data.id))
	if selection:
		logic_print("-- Flipping cards")
		for i : int in selection.size():
			if accuracy_check() == false:
				logic_print("Accuracy check failed.")
				selection[i] = select_random_card(false)
			logic_print("Flipped: " + selection[i].data.id)
			await selection[i].flip()
			await get_tree().create_timer(0.2).timeout
	else:
		push_error("\tNo cards selected. Make sure memory is accurate.")
	degrade_memory()
	logic_print()


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

## Chooses a random active card from the grid. [br]
## The current selection is always excluded. [br]
## If exclude_known is true, anything in memory is also excluded. [br]
func select_random_card(exclude_known: bool) -> Card:
	var available_cards = card_grid.active_cards.duplicate_deep()
	var exclusions : Array[Card] = selection.duplicate_deep()
	var selected_card : Card = null
	if exclude_known:
		exclusions.append_array(card_memory.keys())
	# EXCLUDE
	for card in exclusions:
		available_cards.erase(card)
	# ATTEMPT SELECTION
	if available_cards.size() > 0:
		available_cards.shuffle()
		selected_card = available_cards[0]
		if exclude_known:
			logic_print("Unknown card selected: " + selected_card.data.id + " " + str(selected_card.name))
		else:
			logic_print("Random card selected: " + selected_card.data.id + " " + str(selected_card.name))
	else:
		push_error("Could not select unkown card. All active cards are known or selected.")
	return selected_card

## Searches memory for a match to the given card. [br]
## If no match is found, null is returned.
func find_memory_match(card : Card) -> Card:
	if card == null: return null
	for i : Card in get_cards_by_least_recent():
		if i.data.front == card.data.front:
			return i
	return null

## Prints the current cards in memory along with their remaining lifetimes
func _print_memory_contents() -> void:
	logic_print("Memory Contents (Capacity: {}):".format([data.memory_capacity], "{}"))
	logic_print("".lpad(55, "-"))
	for c : Card in get_cards_by_alphabetical():
		var line : String = "|"
		line += c.data.id.lpad(20) + " | "
		line += str(card_memory[c]) + " turns till forget"
		line += "|".lpad(12)
		logic_print(line)
	logic_print("".lpad(55, "-"))

## Prints only if print_logic is set to true.
func logic_print(string : String = "") -> void:
	if print_logic:
		print(string)

func accuracy_check() -> bool:
	return data.memory_accuracy > randf()


# MEMORY MODIFICATION ----------------------------------------------------------
func remember_card(card : Card) -> void:
	# Check if already known
	if card_memory.has(card):
		#logic_print("Already known: ", card.data.id, ". Memory lifetime refreshed.")
		pass
	else:
		# Connect match signal
		card.just_matched.connect(_on_card_just_matched.bind(card))
		#logic_print(" + Remembered card: ", card.data.id)
	# Add to memory
	card_memory[card] = data.memory_lifetime

func forget_card(card : Card) -> void:
	#logic_print(" - Forgot card: ", card.data.id)
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
			logic_print(c.data.id + " reached memory lifetime end.")
			forget_card(c)


# SIGNALS ----------------------------------------------------------------------
## Flip reaction
func _on_card_grid_card_flipped(card : Card) -> void:
	remember_card(card)
	if card_memory.size() > data.memory_capacity:
		forget_least_recent_card()

## Match reaction
func _on_card_just_matched(card : Card) -> void:
	forget_card(card)
