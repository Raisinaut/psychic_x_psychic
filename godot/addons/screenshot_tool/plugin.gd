@tool
extends EditorPlugin

const screenshot_tool = "res://addons/screenshot_tool/autoload/screenshot_tool/screenshot_tool.tscn"

#var m_editor_debugger_plugin: EditorDebuggerPlugin = preload("res://addons/screenshots/debugger/editor_debugger_plugin.gd").new()
var bottom_panel: Control


func _enable_plugin() -> void:
	add_autoload_singleton("Screenshots", screenshot_tool)
	pass


func _disable_plugin() -> void:
	remove_autoload_singleton("Screenshots")
	pass


func _enter_tree() -> void:
	#add_debugger_plugin(m_editor_debugger_plugin)
	pass


func _exit_tree() -> void:
	#remove_debugger_plugin(m_editor_debugger_plugin)
	pass
