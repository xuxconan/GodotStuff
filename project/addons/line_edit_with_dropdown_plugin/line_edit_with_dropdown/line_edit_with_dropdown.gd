extends LineEdit

@export_group("Dropdown")
@export var dropdown_parent: Node
@export var options: Array:
	get:
		return _options
	set(value):
		_options = value
		if _dropdown:
			deduplicate_options()
			update_dropdown_options()

var _dropdown: ItemList
var _options := ["1231", "3333"]

func _ready() -> void:
	generate_sub_nodes()
	connect_signals()
	
# 动态创建子节点
func generate_sub_nodes() -> void:
	_dropdown = ItemList.new()
	_dropdown.name = "Dropdown"
	deduplicate_options()
	update_dropdown_options()
	
# 连接信号
func connect_signals() -> void:
	focus_entered.connect(_on_focus_entered)
	
# 更新下拉框选项
func update_dropdown_options() -> void:
	_dropdown.clear()
	var curren_text := text
	var text_is_empty := !curren_text or curren_text.replacen(" ", "") == ""
	var filtered_options := _options.filter(func(item: String):
		if !item or item.replacen(" ", "") == "":
			return false
		if text_is_empty:
			return true
		return item.match(curren_text)
	)
	for item in filtered_options:
		_dropdown.add_item(item)
	
# 给选项去重
func deduplicate_options() -> void:
	var deduplicated_options := []
	for item in _options:
		if item in deduplicated_options:
			continue
		deduplicated_options.push_back(item)
	_options.clear()
	_options.append_array(deduplicated_options)
	
# TODO: 还是用itemlist把
func show_dropdown() -> void:
	pass
	
func _on_focus_entered() -> void:
	deduplicate_options()
	update_dropdown_options()
	var current_transform := get_global_transform_with_canvas()
	var current_position := current_transform.origin
	var dropdown_position := Vector2(
		 current_position.x, 
		 current_position.y + size.y
	)
	_dropdown.position = dropdown_position
	_dropdown.max_size.x = size.x
	_dropdown.min_size.x = size.x
	_dropdown.visible = true
