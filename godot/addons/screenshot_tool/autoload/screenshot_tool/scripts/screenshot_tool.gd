extends Node

@export var action_name : String = "screenshot"
@export var action_input : InputEventKey
@export var confirm_before_saving := true
@export var max_buffer_size : int = 30
@export_range(0, 1, 0.01) var save_dialog_screen_scale : float = 0.4

@onready var save_dialog : FileDialog = $SaveDialog
@onready var save_dialog_line_edit = save_dialog.get_line_edit()
@onready var preview_interface = $PreviewInterface

@onready var last_pause_state = get_tree().paused

var shot_buffer : Array[Image] = []
var selected_shot : Image = null :
	set(image):
		selected_shot = image
		update_preview_image()


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	add_screenshot_action()
	close_dialog()
	setup_dialog()
	preview_interface.screenshot_confirmed.connect(open_dialog)
	preview_interface.screenshot_canceled.connect(close_dialog)
	preview_interface.timeline_percent_changed.connect(_on_timeline_changed)
	preview_interface.timeline_thumbnail_value_changed.connect(_on_timeline_thumbnail_value_changed)
	save_dialog_line_edit.text_submitted.connect(_on_line_edit_text_submitted)

func _physics_process(_delta: float) -> void:
	if not OS.is_debug_build():
		return
	if not is_processing_screenshot():
		await update_shot_buffer()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(action_name) and not event.is_echo():
		# Close
		if is_processing_screenshot():
			preview_interface.close()
			close_dialog()
		# Open
		else:
			state_safe_pause()
			selected_shot = shot_buffer[-1]
			if confirm_before_saving:
				var max_buffer_idx = shot_buffer.size() - 1
				preview_interface.set_timeline_steps(max_buffer_idx)
				preview_interface.open()
			else:
				open_dialog()

func add_screenshot_action():
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	InputMap.action_add_event(action_name, action_input)


# PREVIEW ----------------------------------------------------------------------
func update_preview_image() -> void:
	preview_interface.set_preview_image(selected_shot)

func _on_timeline_changed(new_percentage : float) -> void:
	# Sync selected shot with timeline position
	var buffer_idx = lerp(0, shot_buffer.size() - 1, new_percentage)
	selected_shot = shot_buffer[round(buffer_idx)]

func _on_timeline_thumbnail_value_changed(value : float) -> void:
	# retrieve the image at this value
	var buffer_idx = lerp(0, shot_buffer.size() - 1, value)
	var image : Image = shot_buffer[round(buffer_idx)]
	# apply it to the timeline thumbnail
	preview_interface.timeline.set_thumbnail_image(image)


# SCREENSHOT MANAGEMENT --------------------------------------------------------
func save_screenshot(image : Image, directory : String, filename):
	if not OS.is_debug_build() : return
	await RenderingServer.frame_post_draw
	var error = image.save_png(directory + "/" + filename)
	if error == OK:
		print("Screenshot saved to ", directory)
		OS.shell_show_in_file_manager(directory)
	else:
		printerr("Did not save screenshot to ", directory)

func get_viewport_image() -> Image:
	await RenderingServer.frame_post_draw
	return get_viewport().get_texture().get_image()

## Preserves shots up to the buffer size
func update_shot_buffer() -> void:
	if shot_buffer.size() > max_buffer_size:
		shot_buffer.pop_front()
	shot_buffer.append(await get_viewport_image())


# DIALOG -----------------------------------------------------------------------
func setup_dialog():
	var screen_size = DisplayServer.screen_get_size()
	var screen_scale = DisplayServer.screen_get_scale()
	save_dialog.size = screen_size / screen_scale * save_dialog_screen_scale
	
	save_dialog.add_button("Generate Filename", true, "generate_filename")
	save_dialog.confirmed.connect(_on_save_dialog_confirmed)
	save_dialog.visibility_changed.connect(_on_save_dialog_visibility_changed)
	save_dialog.custom_action.connect(_on_save_dialog_custom_action)

func open_dialog():
	save_dialog.show()
	#reset_filename()
	set_filename(generate_default_filename())

func close_dialog():
	save_dialog.hide()
	state_safe_unpause()

## Workaround for window closing issue
#	The window closes when text is submitted to line edit, but nothing is saved.
#	This fixes that behavior but doesn't explain it.
func _on_line_edit_text_submitted(_new_text) ->  void:
	save_selected_shot()

func _on_save_dialog_confirmed() -> void:
	save_selected_shot()

func _on_save_dialog_visibility_changed() -> void:
	if not save_dialog.visible:
		close_dialog()

func _on_save_dialog_custom_action(action : String) -> void:
	match action:
		"generate_filename":
			set_filename(generate_default_filename())

func generate_default_filename() -> String:
	var date = Time.get_date_string_from_system().replace(".","_") 
	var time :String = Time.get_time_string_from_system().replace(":","")
	var project = ProjectSettings.get("application/config/name")
	var filename = project + " " + date + " " + time
	return filename

func reset_filename() -> void:
	set_filename("")

func set_filename(filename : String) -> void:
	save_dialog.get_line_edit().text = filename

func save_selected_shot() -> void:
	var img = selected_shot
	var dir = save_dialog.current_dir
	var filename = save_dialog.get_line_edit().text
	save_screenshot(img, dir, filename)
	close_dialog()


# PAUSING ----------------------------------------------------------------------
func state_safe_pause():
	last_pause_state = get_tree().paused
	get_tree().paused = true

func state_safe_unpause():
	# ensure the game wasn't unpaused by a timer or something
	if not get_tree().paused:
		last_pause_state = false
	get_tree().paused = last_pause_state


# CHECKS -----------------------------------------------------------------------
func is_processing_screenshot() -> bool:
	return save_dialog.visible or preview_interface.visible
