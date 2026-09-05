extends Control

signal confirmed

@onready var name_edit: LineEdit = %NameEdit
@onready var portrait_carousel: Carousel = %PortraitCarousel
@onready var confirm_button: Button = %ConfirmButton


func _ready() -> void:
	name_edit.text = UserData.username
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	portrait_carousel.all_elements_ready.connect(_on_portrait_carousel_all_elements_ready)

func _on_confirm_button_pressed() -> void:
	UserData.username = name_edit.text
	UserData.portrait = portrait_carousel.get_current_element().texture
	confirmed.emit()

func _on_portrait_carousel_all_elements_ready() -> void:
	portrait_carousel.go_to_element_with_texture(UserData.portrait)
