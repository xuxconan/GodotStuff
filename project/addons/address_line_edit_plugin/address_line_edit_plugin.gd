@tool
extends EditorPlugin

func _enter_tree() -> void:
	print("Plugin AddressLineEdit loaded!")
	add_custom_type("AddressLineEdit", "Control", preload("address_line_edit.gd"), null)
	
func _exit_tree() -> void:
	print("Plugin AddressLineEdit unloaded!")
	remove_custom_type("AddressLineEdit")
