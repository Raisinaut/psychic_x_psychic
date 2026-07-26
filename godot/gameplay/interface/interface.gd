extends Control

@onready var opponent_info: PlayerInfo = %OpponentInfo
@onready var user_info: PlayerInfo = %UserInfo
@onready var field_area: Control = %FieldArea

@onready var player_ids : Dictionary[String, PlayerInfo] = {
	"user" : user_info,
	"cpu" : opponent_info
}

var field_input_disabled : bool = false : set = set_field_input_disabled
var highlight_user : bool = true : set = set_highlight_user

func _ready() -> void:
	GameManager.score_changed.connect(_on_game_manager_score_changed)

func set_highlight_user(val) -> void:
	highlight_user = val
	user_info.darkened = not highlight_user
	opponent_info.darkened = highlight_user

func set_field_input_disabled(state) -> void:
	field_input_disabled = state
	if field_input_disabled:
		field_area.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		field_area.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_game_manager_score_changed(id : String, value : int) -> void:
	player_ids[id].set_score(value)
