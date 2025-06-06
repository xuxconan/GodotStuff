@tool
extends Control

var component: Control

func _ready() -> void:
	var packed_scene := preload("directory_line_edit/directory_line_edit.tscn")
	replace_self_with_component.call_deferred(packed_scene)
	
func replace_self_with_component(packed_scene: PackedScene) -> void:
	name = "DirectoryLineEdit_Plugin"
	component = packed_scene.instantiate() as Control
	var parent := get_parent()
	parent.add_child(component)
	component.set_owner(parent)
	component.name = "DirectoryLineEdit"
	parent.remove_child(self)
	