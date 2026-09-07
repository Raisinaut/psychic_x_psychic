extends ControlFader

signal confirmed

@onready var name_edit: LineEdit = %NameEdit
@onready var portrait_carousel: Carousel = %PortraitCarousel
@onready var confirm_button: Button = %ConfirmButton
@onready var title: Label = %Title
@onready var lower_elements: VBoxContainer = %LowerElements
@onready var input_blocker: Control = %InputBlocker


func _ready() -> void:
	name_edit.text = UserData.username
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	portrait_carousel.all_elements_ready.connect(_on_portrait_carousel_all_elements_ready)
	fade_in()

func _on_confirm_button_pressed() -> void:
	confirmed.emit()
	UserData.username = name_edit.text
	UserData.portrait = portrait_carousel.get_current_element().texture

func _on_portrait_carousel_all_elements_ready() -> void:
	portrait_carousel.go_to_element_with_texture(UserData.portrait)

func fade_out() -> void:
	input_blocker.visible = true
	portrait_carousel.flash_container()
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
