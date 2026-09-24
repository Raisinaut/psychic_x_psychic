extends ControlFader

signal confirmed

@onready var name_edit: LineEdit = %NameEdit
@onready var portrait_carousel: Carousel = %PortraitCarousel
@onready var confirm_button: Button = %ConfirmButton
@onready var title: Label = %Title
@onready var lower_elements: VBoxContainer = %LowerElements
@onready var input_blocker: Control = %InputBlocker

# SFX
@onready var cycle_sfx: VariableStreamPlayer = %CycleSFX
@onready var confirm_shimmer_sfx: VariableStreamPlayer = %ConfirmShimmerSFX
@onready var button_press_sfx: AudioStreamPlayer = %ButtonPressSFX
@onready var button_hover_sfx: AudioStreamPlayer = %ButtonHoverSFX


func _ready() -> void:
	connect_button_feedback()
	name_edit.text = UserData.username
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	portrait_carousel.all_elements_ready.connect(_on_portrait_carousel_all_elements_ready)
	portrait_carousel.nav_button_just_pressed.connect(_on_portrait_carousel_nav_button_just_pressed)
	fade_in()

func _on_confirm_button_pressed() -> void:
	confirm_shimmer_sfx.play_random()
	confirmed.emit()
	UserData.username = name_edit.text
	UserData.portrait = portrait_carousel.get_current_element().texture

func _on_portrait_carousel_all_elements_ready() -> void:
	portrait_carousel.go_to_element_with_texture(UserData.portrait)

func _on_portrait_carousel_nav_button_just_pressed() -> void:
	cycle_sfx.play_random()

func fade_out() -> void:
	input_blocker.visible = true
	portrait_carousel.flash_container()
	portrait_carousel.allow_navigation = false
	await fade_out_element(confirm_button).finished
	await get_tree().create_timer(0.2).timeout
	#await fade_out_element(title).finished
	await fade_out_element(self).finished

func fade_in() -> void:
	input_blocker.visible = true
	reset_fade()
	await fade_in_element(self).finished
	await fade_in_element(title).finished
	await fade_in_element(portrait_carousel).finished
	await fade_in_element(lower_elements).finished
	input_blocker.visible = false

func reset_fade() -> void:
	modulate.a = 0
	title.modulate.a = 0
	portrait_carousel.modulate.a = 0
	lower_elements.modulate.a = 0


# AUDIO FEEDBACK ---------------------------------------------------------------
func connect_button_feedback(node: Node = self, current_depth : int = 0) -> void:
	for i in node.get_children():
		if i is Button:
			i.pressed.connect(play_button_press_sfx)
			i.mouse_entered.connect(play_button_hover_sfx)
		else:
			connect_button_feedback(i, current_depth + 1)

func play_button_press_sfx() -> void:
	button_press_sfx.play()

func play_button_hover_sfx() -> void:
	button_hover_sfx.play()
