## 地址输入栏的主要逻辑类
extends Node

## 组件对外暴露脚本
@export var exposer: AddressLineEditExpose

@export_group("Prefabs")
## 分隔符按钮预制体
@export var seperate_button_prefab: PackedScene

@export_group("Nodes")
## 根节点
@export var root_node: Control
## 模式切换容器
@export var mode_container: TabContainer
## 地址输入组件
@export var line_edit: LineEdit
## 地址按钮组容器
@export var button_group: Container
## 按钮组的模式触发区
@export var button_group_mode_trigger_zone: Panel
## 提示窗口
@export var dialog: AcceptDialog

enum MODE { LINE_EDIT = 0, BUTTON_GROUP = 1 }

# 用户可能会输入不存在的地址，因此这里需要缓存上次用户输入的有效地址，当用户输入无效地址时重置为旧的地址
var avalible_text := ""

func _ready() -> void:
	# 属性初始化
	line_edit.text = exposer.text
	line_edit.placeholder_text = exposer.placeholder_text
	mode_container.current_tab = MODE.BUTTON_GROUP
	update_button_group()
	# 信号链接
	line_edit.text_changed.connect(_on_line_edit_text_changed)
	line_edit.focus_exited.connect(_on_line_edit_focus_exited)
	line_edit.text_submitted.connect(_on_line_edit_text_submitted)
	button_group.gui_input.connect(_on_button_group_gui_input)
	button_group_mode_trigger_zone.gui_input.connect(_on_button_group_mode_trigger_zone_gui_input)

# 当文字改变时同步到外部
func _on_line_edit_text_changed(new_text: String) -> void:
	exposer.text = new_text
	
# 输入框丢失焦点时切换到按钮面板
func _on_line_edit_focus_exited() -> void:
	switch_to_button_group()

# 输入框按下回车时切换到按钮面板
func _on_line_edit_text_submitted(new_text: String) -> void:
	exposer.text = new_text
	switch_to_button_group()

# 点击按钮面板时切换到输入框面板
func _on_button_group_gui_input(event: InputEvent) -> void:
	var button_event := event as InputEventMouseButton
	if button_event and button_event.button_index == 1 and button_event.pressed == false:
		switch_to_line_edit()
	
# 点击按钮面板触发区时切换到输入框面板
func _on_button_group_mode_trigger_zone_gui_input(event: InputEvent) -> void:
	var button_event := event as InputEventMouseButton
	if button_event and button_event.button_index == 1 and button_event.pressed == false:
		switch_to_line_edit()

# 切换到按钮组
func switch_to_button_group() -> void:
	update_button_group()
	mode_container.current_tab = MODE.BUTTON_GROUP
	
# 切换到输入框
func switch_to_line_edit() -> void:
	mode_container.current_tab = MODE.LINE_EDIT
	line_edit.grab_focus()
		
# 更新按钮组
func update_button_group() -> void:
	# 判断地址是否有效
	var text := line_edit.text
	var exist := DirAccess.dir_exists_absolute(text)
	if not exist:
		line_edit.text = avalible_text
		dialog.title = "警告"
		dialog.dialog_text = "输入的地址无效"
		dialog.show()
		return
	avalible_text = text
	# 清除按钮组
	var children := button_group.get_children()
	for child in children:
		button_group.remove_child(child)
	# 将地址分解成路径列表
	text = text.replacen("\\", "/") ## 统一分隔符
	var path_list := text.split("/")
	for i in range(path_list.size()):
		var index := path_list.size() - 1 - i
		if index < 0:
			break
		if path_list[index] == "": # 移除为空的地址
			path_list.remove_at(index)
	if path_list.size() == 0:
		mode_container.current_tab = MODE.LINE_EDIT
		return
	# 根据地址片段生成地址按钮和分割按钮
	var button_path_list := []
	for path_segment in path_list:
		# 动态创建地址按钮，点击后将路径重置到当前按钮为止的路径
		button_path_list.push_back(path_segment)
		var button_path := "/".join(button_path_list)
		var path_button = Button.new()
		path_button.text = path_segment
		path_button.button_up.connect(func():
			line_edit.text = button_path
			update_button_group.call_deferred() # 更新按钮组
		)
		button_group.add_child(path_button)
		# 实例化分割按钮，点击后显示该路径下的子路径
		var path_dir := DirAccess.open(button_path)
		var sub_directories := path_dir.get_directories()
		if sub_directories.size() == 0: # 无子路径的话不显示按钮
			return
		var seperate_button := seperate_button_prefab.instantiate() as AddressSeperateButtonExpose
		seperate_button.options_parent = root_node
		seperate_button.options = sub_directories
		seperate_button.item_selected.connect(func(_index: int, content: String):
			line_edit.text = button_path + "/" + content
			update_button_group.call_deferred() # 更新按钮组
		)
		button_group.add_child(seperate_button)
