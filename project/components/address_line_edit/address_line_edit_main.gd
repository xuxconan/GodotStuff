## 地址输入栏的主要逻辑类
extends Node

## 组件对外暴露脚本
@export var exposer: AddressLineEditExpose

@export_group("Nodes")
## 根节点
@export var root_node: Control
## 模式切换容器
@export var mode_container: TabContainer
## 输入框容器
@export var line_edit_container: AddressLineEditLineEditContainer
## 按钮组容器
@export var button_group_container: AddressLineEditButtonGroupContainer
## 提示窗口
@export var dialog: AcceptDialog

signal sync_text_to_sub_components(new_text: String)
signal request_line_edit_to_grab_focus()

enum MODE { LINE_EDIT = 0, BUTTON_GROUP = 1 }

# 用户可能会输入不存在的地址，因此这里需要缓存上次用户输入的有效地址，当用户输入无效地址时重置为旧的地址
var available_text := ""

func _ready() -> void:
	# 信号链接
	sync_text_to_sub_components.connect(line_edit_container._on_available_address_text_changed)
	sync_text_to_sub_components.connect(button_group_container._on_available_address_text_changed)
	request_line_edit_to_grab_focus.connect(line_edit_container._on_request_line_edit_to_grab_focus)
	line_edit_container.line_edit_text_changed.connect(_on_line_edit_container_text_changed)
	line_edit_container.line_edit_focus_exited.connect(_on_line_edit_container_focus_exited)
	line_edit_container.line_edit_text_submitted.connect(_on_line_edit_container_text_submitted)
	button_group_container.trigger_mode_to_line_edit.connect(switch_to_line_edit)
	button_group_container.address_text_changed.connect(_on_button_group_container_text_changed)

	# 属性初始化
	button_group_container.options_parent = root_node
	var init_text := exposer.text
	if check_address_available(init_text) and available_text != init_text:
		available_text = init_text
		sync_text_to_sub_components.emit(init_text)
	if available_text == "":
		mode_container.current_tab = MODE.LINE_EDIT
	else:
		mode_container.current_tab = MODE.BUTTON_GROUP

# 当文字改变时同步到外部
func _on_line_edit_container_text_changed(new_text: String) -> void:
	if !check_address_available(new_text):
		sync_text_to_sub_components.emit(available_text)
		alert_invalid_address()
		return
	if available_text == new_text:
		return
	available_text = new_text
	exposer.text = new_text
	sync_text_to_sub_components.emit(new_text)
	
# 输入框丢失焦点时切换到按钮面板
func _on_line_edit_container_focus_exited() -> void:
	switch_to_button_group()

# 输入框按下回车时切换到按钮面板
func _on_line_edit_container_text_submitted(new_text: String) -> void:
	if !check_address_available(new_text):
		sync_text_to_sub_components.emit(available_text)
		alert_invalid_address()
		return
	switch_to_button_group()
	if available_text == new_text:
		return
	available_text = new_text
	exposer.text = new_text
	sync_text_to_sub_components.emit(new_text)

# 当文字改变时同步到外部
func _on_button_group_container_text_changed(new_text: String) -> void:
	if !check_address_available(new_text):
		sync_text_to_sub_components.emit(available_text)
		alert_invalid_address()
		return
	if available_text == new_text:
		return
	available_text = new_text
	exposer.text = new_text
	sync_text_to_sub_components.emit(new_text)

# 切换到按钮组
func switch_to_button_group() -> void:
	mode_container.current_tab = MODE.BUTTON_GROUP
	
# 切换到输入框
func switch_to_line_edit() -> void:
	mode_container.current_tab = MODE.LINE_EDIT
	request_line_edit_to_grab_focus.emit()
		
# 检查地址是否有效
func check_address_available(text: String) -> bool:
	var exist := DirAccess.dir_exists_absolute(text)
	if not exist:
		return false
	return true
	
# 警告地址无效
func alert_invalid_address() -> void:
	dialog.title = "警告"
	dialog.dialog_text = "输入的地址无效"
	dialog.show()
