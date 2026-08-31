class_name TextReveal
extends RichTextLabel

signal revealed_more
signal fully_visible

enum RevealChunks {
	LETTER,
	WORD
}

enum RevealModes {
	FLUID,
	STATIC
}

@export var reveal_pause := 0.025
@export var reveal_chunk :=  RevealChunks.LETTER
@export var reveal_mode :=  RevealModes.FLUID

var reveal_progress : int = 0
var original_text: String = ""
var character_pauses : Dictionary[String, float] = {
	"," : 0.0,
	"." : 0.3,
	"!" : 0.3,
	"?" : 0.3,
	":" : 0.2,
	"-" : 0.3
}


func _ready():
	bbcode_enabled = true
	insert_newlines(" ")
	revealed_more.connect(reveal_more)
	visible_characters = 0

func update_text(_text : String) -> void:
	text = _text
	original_text = text
	insert_newlines(" ")


# REVEAL METHODS ---------------------------------------------------------------
func _next_character_idx() -> int:
	return reveal_progress + 1

func _next_word_idx() -> int:
	var word_end_idx : int = original_text.find(" ", reveal_progress + 1)
	var word_length : int = max(word_end_idx - reveal_progress, -1)
	var word: String = original_text.substr(reveal_progress, word_length)
	return reveal_progress + word.length()

func reveal_more():
	if is_fully_visible():
		fully_visible.emit()
		return
	
	# Get reveal index
	match reveal_chunk:
		RevealChunks.LETTER:
			reveal_progress = _next_character_idx()
		RevealChunks.WORD:
			reveal_progress = _next_word_idx()
	
	# Reveal progress
	match reveal_mode:
		RevealModes.FLUID:
			visible_characters = reveal_progress
		RevealModes.STATIC:
			visible_characters = -1 # show all chars, control opacity below
			text = original_text
			text = text.insert(reveal_progress, "[color=ffffff00]")
			text = text.insert(-1, "[/style]")
	
	# Pause between reveals
	var pause_duration : float = reveal_pause
	var final_character = original_text[reveal_progress - 1]
	if character_pauses.has(final_character):
		pause_duration += character_pauses[final_character]
	await get_tree().create_timer(pause_duration, false).timeout
	revealed_more.emit()

func reveal_all():
	if not is_fully_visible():
		fully_visible.emit()
	visible_characters = -1
	reveal_progress = original_text.length() - 1
	match reveal_mode:
		RevealModes.STATIC:
			text = original_text


# CHECKS -----------------------------------------------------------------------
func is_fully_visible() -> bool:
	match reveal_mode:
		RevealModes.FLUID:
			return visible_characters >= original_text.length()
		RevealModes.STATIC:
			return reveal_progress >= original_text.length()
		_:
			push_warning("Invalid text reveal mode.")
			return false


# UTILITY ----------------------------------------------------------------------
## Parses the text and progressively 
## inserts the argument string at each newline.
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
