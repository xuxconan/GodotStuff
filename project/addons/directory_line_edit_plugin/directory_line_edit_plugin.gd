@tool
extends EditorPlugin

func _enter_tree() -> void:
	print("Plugin DirectoryLineEdit loaded!")
	add_custom_type("DirectoryLineEdit", "Control", preload("directory_line_edit.gd"), null)
	
func _exit_tree() -> void:
	print("Plugin DirectoryLineEdit unloaded!")
	remove_custom_type("DirectoryLineEdit")
