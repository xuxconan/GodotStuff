@tool
extends LineEdit

var component: Control

func _ready() -> void:
	var packed_scene := preload(
		"line_edit_with_dropdown/line_edit_with_dropdown.tscn"
	)
	replace_self_with_component.call_deferred(packed_scene)

func replace_self_with_component(packed_scene: PackedScene) -> void:
	name = "LineEditWithDropdownInstantiator"
	component = packed_scene.instantiate() as LineEdit
	var parent := get_parent()
	parent.add_child(component)
	component.set_owner(parent)
	component.name = "LineEditWithDropdown"
	parent.remove_child(self)
	