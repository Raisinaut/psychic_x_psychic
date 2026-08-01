@tool
extends ColorRect


var palette : Texture = null : set = set_palette

func set_palette(val) -> void:
	palette = val
	set_shader_palette(palette)

func set_shader_palette(val) -> void:
	var mat : ShaderMaterial = material
	mat.set_shader_parameter("palette", val)
