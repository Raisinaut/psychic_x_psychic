class_name TextReveal
extends Label

signal revealed_character
signal fully_visible

@export var reveal_pause := 0.03

var character_pauses = {
	"," : 0.0,
	"." : 0.3,
	"!" : 0.3,
	"?" : 0.3,
	":" : 0.2,
	"-" : 0.3
}

var settings_override: LabelSettings = null


func _ready():
	_match_data()
	revealed_character.connect(reveal_next_character)
	visible_characters = 0
	#reveal_next_character()


func _match_data():
	if settings_override != null:
		label_settings = settings_override
	insert_newlines(" ")


func reveal_next_character():
	if is_fully_visible():
		fully_visible.emit()
		return
	# check for an additional wait
	var next_character = text.substr(visible_characters, 1)
	var additional_pause = 0.0
	if character_pauses.has(next_character):
		additional_pause = character_pauses[next_character]
	#SpeakerAudio.play_char_sound(next_character)
	# reveal next character
	visible_characters += 1
	await get_tree().create_timer(reveal_pause + additional_pause).timeout
	revealed_character.emit()


func reveal_all():
	if not is_fully_visible():
		fully_visible.emit()
	visible_characters = text.length()


func is_fully_visible() -> bool:
	return visible_characters >= text.length()


# reads through the text and progressively 
# inserts the argument string at each newline
func insert_newlines(additional_str := ""):
	# start with all characters invisible
	visible_characters = 0
	var current_line_count = get_line_count()
	var total_characters = text.length()
	for t in total_characters:
		# check if a new line was just created
		if current_line_count < get_line_count():
			# get the visible text to this point
			var text_so_far = text.substr(0, visible_characters)
			# find how long the word is that starts the new line
			var word_start_offset = text_so_far.reverse().find(" ")
			# find the index of the space that would end the initial line
			var newline_index = (visible_characters - word_start_offset - 1)
			# delete the space
			text = text.erase(newline_index)
			# concatenate the newline and additional string
			var newline_str = "\n" + additional_str
			# insert it where the deleted space was
			text = text.insert(newline_index, newline_str)
			# account for newline string length, subtract 1 for deleted space
			visible_characters += newline_str.length() - 1
			# match the new line count
			current_line_count = get_line_count()
		# show the next character
		visible_characters += 1
