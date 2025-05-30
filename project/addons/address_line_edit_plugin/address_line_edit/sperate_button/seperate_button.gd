class_name AddressLineEditSeperateButton
extends Control

@export_group("Nodes")
## 用来触发选项显示隐藏的按钮
@export var trigger_button: Button
## 选项列表
@export var options_list: ItemList

@export_group("Options")
## 选项列表挂载的父节点
@export var options_parent: Control
## 选项列表相对于按钮的偏移
@export var options_offset := Vector2(0.0, 5.0)
## 选项列表数据
@export var options := []

## 选项被选中时的信号
signal item_selected(index: int, content: String)

func _ready() -> void:
	# 初始化属性
	options_list.visible = false
	# 链接信号
	options_list.item_selected.connect(_on_options_list_item_selected)
	trigger_button.toggled.connect(_on_trigger_button_toggled)
	trigger_button.focus_exited.connect(_on_trigger_button_focus_exited.call_deferred) # 立即隐藏选项列表会导致选项信号无法触发
	
# 当下拉列表被选中时向组件外释放信号
func _on_options_list_item_selected(index: int) -> void:
	var content := options_list.get_item_text(index)
	item_selected.emit(index, content)
	
# 当按钮被激活时显示选项列表，当按钮被取消激活时隐藏选项列表
func _on_trigger_button_toggled(toggled_on: bool) -> void:
	options_list.visible = toggled_on
	if toggled_on:
		remount_options_list()
		update_options_list()

# 当按钮丢失焦点时取消触发
func _on_trigger_button_focus_exited() -> void:
	trigger_button.button_pressed = false

# 将列表移动到指定父节点下		
func remount_options_list() -> bool:
	var old_parent := options_list.get_parent()
	if old_parent:
		old_parent.remove_child(options_list)
	var new_parent := options_parent
	if !new_parent:
		new_parent = old_parent
	if !new_parent:
		return false
	new_parent.add_child(options_list)
	# 修改弹出位置到按钮下方
	var parent_transform := new_parent.get_global_transform_with_canvas()
	var button_transform := trigger_button.get_global_transform_with_canvas()
	var relative_transform := parent_transform * button_transform.affine_inverse()
	var relative_position := relative_transform.origin
	relative_position.x *= -1
	relative_position.y += trigger_button.size.y
	var offset := options_offset
	if offset:
		relative_position += offset
	options_list.position = relative_position
	return true
	
# 根据暴露的选项列表变量更新显示列表
func update_options_list() -> void:
	options_list.clear()
	for text in options:
		options_list.add_item(text)
