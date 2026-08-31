extends ControlFader

signal rematch_selected
signal main_menu_selected
signal new_opponent_selected

@onready var result_label: Label = %ResultLabel
@onready var message_label: TextReveal = %MessageLabel
@onready var portrait: TextureRect = %Portrait
@onready var content_container: PanelContainer = %ContentContainer
@onready var message_container: PanelContainer = %MessageContainer
@onready var noise_effect: ColorRect = %NoiseEffect
@onready var noise_darken: ColorRect = %NoiseDarken

@onready var button_container: VBoxContainer = %ButtonContainer
@onready var rematch_button: Button = %RematchButton
@onready var new_opponent_button: Button = %NewOpponentButton
@onready var main_menu_button: Button = %MainMenuButton

enum ContentModes {
	DISABLED,
	MESSAGE,
	CHOICES
}
var content_mode := ContentModes.DISABLED


func _ready() -> void:
	noise_effect.visible = true # disabled in editor to conserve resources
	rematch_button.pressed.connect(rematch_selected.emit)
	main_menu_button.pressed.connect(main_menu_selected.emit)
	new_opponent_button.pressed.connect(new_opponent_selected.emit)

func show_message() -> void:
	content_mode = ContentModes.MESSAGE
	message_label.visible_characters = 0
	await fade_in_element(result_label).finished
	await fade_in_element(message_container).finished
	await fade_in_element(portrait).finished
	await fade_in_element(noise_effect, 0.0).finished
	await fade_out_element(noise_darken).finished
	message_label.reveal_more()

func show_choices() -> void:
	content_mode = ContentModes.CHOICES
	await fade_in_element(noise_darken).finished
	await fade_out_element(noise_effect, 0.0).finished
	await fade_out_element(message_container).finished
	button_container.visible = true
	await fade_in_element(button_container).finished

func reset_fade() -> void:
	visible = false
	self.modulate.a = 0
	# message container
	result_label.modulate.a = 0
	message_container.modulate.a = 0
	portrait.modulate.a = 0
	noise_effect.modulate.a = 0
	noise_darken.modulate.a = 1.0
	# button container
	button_container.visible = false
	button_container.modulate.a = 0

func update_results(data : OpponentData, lose_override := false) -> void:
	var results = GameManager.get_game_results()
	if lose_override:
		results = GameManager.GameResults.P2_WIN
	portrait.texture = data.portrait
	match(results):
		GameManager.GameResults.P1_WIN:
			result_label.text = "YOU WIN"
			message_label.update_text(data.phrase_lose)
		GameManager.GameResults.P2_WIN:
			result_label.text = "YOU LOSE"
			message_label.update_text(data.phrase_win)
		GameManager.GameResults.TIE:
			result_label.text = "TIE"
			message_label.update_text(data.phrase_tie)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and not event.is_echo():
			handle_mouse_click()

func handle_mouse_click() -> void:
	match(content_mode):
		ContentModes.DISABLED:
			pass
		ContentModes.MESSAGE:
			if is_fading():
				skip_fade()
			elif content_container.modulate.a == 1.0:
				if message_label.is_fully_visible():
					show_choices()
				else:
					print("skip text")
					message_label.reveal_all()
		ContentModes.CHOICES:
			pass

func update_available_choices(results : GameManager.GameResults) -> void:
	main_menu_button.visible = true
	match(results):
		GameManager.GameResults.P1_WIN:
			rematch_button.visible = false
		GameManager.GameResults.P2_WIN:
			rematch_button.visible = true
		GameManager.GameResults.TIE:
			rematch_button.visible = true

func skip_fade() -> void:
	fade_tween.custom_step(1000)

func fade_in() -> void:
	visible = true
	await fade_in_element(self).finished
	match(content_mode):
		ContentModes.MESSAGE:
			show_message()
		ContentModes.CHOICES:
			show_choices()

func fade_out() -> void:
	content_mode = ContentModes.DISABLED
	await fade_out_element(self).finished
	reset_fade()
