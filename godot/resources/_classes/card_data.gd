class_name CardData
extends Resource

@export var id : String = ""
@export var front : Texture
@export var action_name : String = ""

func has_action() -> bool:
	return action_name != ""
