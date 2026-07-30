extends ControlFader

@onready var result_label: Label = %ResultLabel
@onready var message_label: TextReveal = %MessageLabel
@onready var portrait: TextureRect = %Portrait
@onready var message_container: PanelContainer = %MessageContainer
@onready var noise_effect: ColorRect = %NoiseEffect
@onready var noise_darken: ColorRect = %NoiseDarken

func _ready() -> void:
	visible = false
	self.modulate.a = 0
	result_label.modulate.a = 0
	portrait.modulate.a = 0
	message_container.modulate.a = 0
	noise_effect.modulate.a = 0
	noise_darken.modulate.a = 1.0

func display_results(results : GameManager.GameResults, data : OpponentData) -> void:
	portrait.texture = data.portrait
	match(results):
		GameManager.GameResults.P1_WIN:
			result_label.text = "YOU WIN"
			message_label.text = data.phrase_lose
		GameManager.GameResults.P2_WIN:
			result_label.text = "YOU LOSE"
			message_label.text = data.phrase_win
		GameManager.GameResults.TIE:
			result_label.text = "TIE"
			message_label.text = data.phrase_tie
	fade_in()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and not event.is_echo():
			if is_fading():
				skip_fade()
			elif message_container.modulate.a == 1.0:
				print("skip text")
				message_label.reveal_all()

func skip_fade() -> void:
	fade_tween.custom_step(1000)

func fade_in() -> void:
	visible = true
	await fade_in_element(self).finished
	await fade_in_element(result_label).finished
	await fade_in_element(message_container).finished
	await fade_in_element(portrait).finished
	await fade_in_element(noise_effect, 0.0).finished
	await fade_out_element(noise_darken).finished
	message_label.reveal_next_character()

func fade_out() -> void:
	push_error("no fade out sequence programmed")
	pass
