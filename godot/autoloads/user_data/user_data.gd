extends Node

signal username_changed(new_username: String)
signal portrait_changed(new_portrait: Texture)

var username : String = "" : set = set_username
var portrait : Texture = null : set = set_portrait

func set_username(new_username: String) -> void:
	new_username = new_username.lstrip(" ") # remove leading spaces
	new_username = new_username.rstrip(" ") # remove trailing spaces
	username = new_username
	username_changed.emit(username)
	#print("Username changed to: ", username)

func set_portrait(new_portrait: Texture) -> void:
	portrait = new_portrait
	portrait_changed.emit(portrait)
	#print("Portrait changed to: ", portrait)
