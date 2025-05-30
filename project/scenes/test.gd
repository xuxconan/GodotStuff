extends Node

func _ready() -> void:
	var root := Control.new()
	root.name = "TestScene"
	var button := Button.new()
	button.name = "TestButton"
	button.text = "Test!"
	button.pressed.connect(func():
		print("I'm pressed!")
	)
	root.add_child(button)
	button.set_owner(root)
	var packedscene := PackedScene.new()
	packedscene.pack(root)
	var scene := packedscene.instantiate()
	scene.name = "PackedScene"
	var parent := get_parent()
	parent.add_child(scene)
	scene.set_owner(parent)
	print("parent: ", parent, ",scene: ", scene, ",parent_children: ", parent.get_children())
#	parent.add_child(root)