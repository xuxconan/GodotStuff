extends ItemList

var parent: Control

func _ready() -> void:
	item_selected.connect(_on_item_selected)
	add_item("1")
	add_item("2")
	add_item("3")
	remove_from_parent.call_deferred()

func _on_item_selected(index: int) -> void:
	var content := get_item_text(index)
	print(index, "@@", content)
	
func remove_from_parent() -> void:
	parent = get_parent()
	parent.remove_child(self)
	print(parent, "!!", self, "!!", parent.get_children())
	remount_to_parent.call_deferred()
	
func remount_to_parent() -> void:
	parent.add_child(self)
	print(parent, "??", self, "??", parent.get_children())