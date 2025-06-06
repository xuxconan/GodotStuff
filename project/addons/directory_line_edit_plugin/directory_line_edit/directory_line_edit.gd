## 地址输入栏的主要逻辑类
extends Control

@export_group("LineEdit")
## 初始化地址文字
@export var text := ""
## 占位文字
@export var placeholder_text := "请输入地址"
## 历史列表
@export var history: Array:
	get:
		return _history
	set(value):
		if value:
			_history = value
			if line_edit_container:
				line_edit_container.set("history", _history)

@export_group("Nodes")
## 根节点
@export var root_node: Control
## 模式切换容器
@export var mode_container: TabContainer
## 输入框容器
@export var line_edit_container: Control
## 按钮组容器
@export var button_group_container: Control
## 提示窗口
@export var dialog: AcceptDialog

signal sync_directory(new_text: String)
signal request_line_edit_to_grab_focus()

enum MODE { LINE_EDIT = 0, BUTTON_GROUP = 1 }

# 用户可能会输入不存在的地址，因此这里需要缓存上次用户输入的有效地址，当用户输入无效地址时重置为旧的地址
var available_text := ""
# 真正的历史记录列表
var _history := []

func _ready() -> void:
	# 信号链接
	var bg_func_sync_directory := button_group_container.get("_on_request_sync_directory") as Callable
	sync_directory.connect(bg_func_sync_directory)
	var le_func_sync_directory := line_edit_container.get("_on_request_sync_directory") as Callable
	sync_directory.connect(le_func_sync_directory)
	var le_func_grab_focus := line_edit_container.get("_on_request_grab_focus") as Callable
	request_line_edit_to_grab_focus.connect(le_func_grab_focus)

	var bg_signal_request_line_edit_mode := button_group_container.get("request_line_edit_mode") as Signal
	bg_signal_request_line_edit_mode.connect(switch_to_line_edit)
	var bg_signal_directory_changed := button_group_container.get("directory_changed") as Signal
	bg_signal_directory_changed.connect(_on_button_group_container_text_changed)
	var le_signal_focus_exited := line_edit_container.get("line_edit_focus_exited") as Signal
	le_signal_focus_exited.connect(_on_line_edit_container_focus_exited)
	var le_signal_text_submitted := line_edit_container.get("line_edit_text_submitted") as Signal
	le_signal_text_submitted.connect(_on_line_edit_container_text_submitted)

	# 属性初始化
	line_edit_container.set("history", _history)
	line_edit_container.set("history_parent", root_node)
	button_group_container.set("options_parent", root_node)
	var init_text := text
	if check_directory_available(init_text) and available_text != init_text:
		available_text = init_text
		sync_directory.emit(init_text)
	if available_text == "":
		mode_container.current_tab = MODE.LINE_EDIT
	else:
		mode_container.current_tab = MODE.BUTTON_GROUP
		
# 输入框丢失焦点时切换到按钮面板
func _on_line_edit_container_focus_exited() -> void:
	switch_to_button_group()
	
# 输入框按下回车时切换到按钮面板
func _on_line_edit_container_text_submitted(new_text: String) -> void:
	if !check_directory_available(new_text):
		sync_directory.emit(available_text)
		alert_invalid_directory()
		return
	switch_to_button_group()
	if available_text == new_text:
		return
	available_text = new_text
	text = new_text
	sync_directory.emit(new_text)

# 当文字改变时同步到外部
func _on_button_group_container_text_changed(new_text: String) -> void:
	if !check_directory_available(new_text):
		sync_directory.emit(available_text)
		alert_invalid_directory()
		return
	if available_text == new_text:
		return
	available_text = new_text
	text = new_text
	sync_directory.emit(new_text)

# 切换到按钮组
func switch_to_button_group() -> void:
	mode_container.current_tab = MODE.BUTTON_GROUP
	
# 切换到输入框
func switch_to_line_edit() -> void:
	mode_container.current_tab = MODE.LINE_EDIT
	request_line_edit_to_grab_focus.emit()
		
# 检查地址是否有效
func check_directory_available(text: String) -> bool:
	var exist := DirAccess.dir_exists_absolute(text)
	if not exist:
		return false
	return true
	
# 警告地址无效
func alert_invalid_directory() -> void:
	dialog.title = "警告"
	dialog.dialog_text = "输入的地址无效"
	dialog.show()
	