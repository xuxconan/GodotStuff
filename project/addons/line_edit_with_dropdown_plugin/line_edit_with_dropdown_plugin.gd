@tool
extends EditorPlugin

func _enter_tree() -> void:
	print("Plugin LineEditWithDropdown loaded!")
	add_custom_type(
		"LineEditWithDropdown", 
		"LineEdit", 
		preload("line_edit_with_dropdown_instantiator.gd"), 
		null
	)

func _exit_tree() -> void:
	print("Plugin LineEditWithDropdown unloaded!")
	remove_custom_type("LineEditWithDropdown")