extends Control

@export_group("History")
## 选项列表挂载的父节点
@export var history_parent: Control
## 选项列表相对于按钮的偏移
@export var history_offset := Vector2(0.0, 5.0)
## 选项列表数据
@export var history := []

@export_group("Nodes")
## 地址输入组件
@export var line_edit: LineEdit
## 选项列表
@export var history_list: ItemList

signal line_edit_focus_exited()
signal line_edit_text_submitted(new_text: String)

var _is_line_edit_focus := false
var _is_history_list_focus := false

var is_line_edit_focus: bool:
	get:
		return _is_line_edit_focus
	set(value):
		_is_line_edit_focus = value
		if !is_component_focus:
			toggle_history_list(false)

var is_history_list_focus: bool:
	get:
		return _is_history_list_focus
	set(value):
		_is_history_list_focus = value
		if !is_component_focus:
			toggle_history_list(false)
	
var is_component_focus := false:
	get:
		var value := _is_line_edit_focus or _is_history_list_focus
		return value

func _ready() -> void:
	# 属性初始化
	history_list.visible = false
	# 信号链接
	line_edit.focus_entered.connect(_on_line_edit_focus_entered)
	line_edit.focus_exited.connect(_on_line_edit_focus_exited)
	line_edit.text_changed.connect(_on_line_edit_text_changed)
	line_edit.text_submitted.connect(_on_line_edit_text_submitted)
	history_list.focus_entered.connect(_on_history_list_focus_entered)
	history_list.focus_exited.connect(_on_history_list_focus_exited)
	history_list.item_selected.connect(_on_history_list_item_selected)
	
# 输入框获取焦点时显示历史记录
func _on_line_edit_focus_entered() -> void:
	is_line_edit_focus = true
	toggle_history_list(true)
	
# 输入框丢失焦点时切换到按钮面板
func _on_line_edit_focus_exited() -> void:
	is_line_edit_focus = false
	if !is_component_focus:
		var new_text := line_edit.text
		line_edit_focus_exited.emit()
		line_edit_text_submitted.emit(new_text)

# 输入框文字变更时释放信号
func _on_line_edit_text_changed(new_text: String) -> void:
	update_history_list(new_text)

# 输入框按下回车时切换到按钮面板
func _on_line_edit_text_submitted(new_text: String) -> void:
	line_edit_focus_exited.emit()
	line_edit_text_submitted.emit(new_text)
	
# 下拉框获取焦点
func _on_history_list_focus_entered() -> void:
	is_history_list_focus = true

# 下拉框失去焦点
func _on_history_list_focus_exited() -> void:
	is_history_list_focus = false
	if !is_component_focus:
		var new_text := line_edit.text
		line_edit_focus_exited.emit()
		line_edit_text_submitted.emit(new_text)

# 选择了历史记录
func _on_history_list_item_selected(index: int) -> void:
	var new_text := history_list.get_item_text(index)
	line_edit_focus_exited.emit()
	line_edit_text_submitted.emit(new_text)

# 当占位字符串变化时同步占位字符
func _on_request_sync_placeholder(new_text: String) -> void:
	line_edit.placeholder_text = new_text
	
# 当文字变化时同步文字
func _on_request_sync_directory(new_text: String) -> void:
	line_edit.text = new_text
	push_new_history(new_text)
	
# 让输入框获取焦点
func _on_request_grab_focus() -> void:
	line_edit.grab_focus()

# 将列表移动到指定父节点下		
func remount_history_list() -> bool:
	var old_parent := history_list.get_parent()
	if old_parent:
		old_parent.remove_child(history_list)
	var new_parent := history_parent
	if !new_parent:
		new_parent = old_parent
	if !new_parent:
		return false
	new_parent.add_child(history_list)
	# 修改弹出位置到按钮下方
	var parent_transform := new_parent.get_global_transform_with_canvas()
	var button_transform := get_global_transform_with_canvas()
	var relative_transform := parent_transform * button_transform.affine_inverse()
	var relative_position := relative_transform.origin
	relative_position.x *= -1
	relative_position.y += size.y
	var offset := history_offset
	if offset:
		relative_position += offset
	history_list.position = relative_position
	return true
	
# 更新历史列表
func update_history_list(changed_text: String) -> void:
	history_list.clear()
	var formated_text := changed_text.replacen("\\", "/")
	var is_empty := formated_text.replacen(" ", "") == ""
	var filtered_history := history.filter(func(str: String):
		if is_empty:
			return true
		return formated_text in str
	)
	if !is_empty:
		filtered_history.sort()
	if filtered_history.size() == 1 and filtered_history[0] == formated_text:
		filtered_history.clear()
	for text in filtered_history:
		history_list.add_item(text)

# 新增历史记录
func push_new_history(new_text: String) -> void:
	var formated_text := new_text.replacen("\\", "/")
	history.push_back(formated_text)
	var filtered_array := []
	for item in history:
		if !item or item.replacen(" ", "") == "":
			continue
		if item in filtered_array:
			continue
		filtered_array.push_back(item)
	history.clear()
	history.append_array(filtered_array)
	update_history_list(formated_text)
	
# 显示/隐藏历史列表
func toggle_history_list(show: bool) -> void:
	if show:
		remount_history_list()
	update_history_list(line_edit.text)
	history_list.visible = show
