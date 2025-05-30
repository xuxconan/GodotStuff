@tool
extends Control

func _ready() -> void:
	var packed_scene := preload("address_line_edit/address_line_edit.tscn")
	create_elements.call_deferred(packed_scene)
	
func create_elements(packed_scene: PackedScene) -> void:
	var scene := packed_scene.instantiate() as Control
	add_child(scene)
	scene.set_anchors_and_offsets_preset(LayoutPreset.PRESET_FULL_RECT)
	