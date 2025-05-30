class_name AddressLineEditButtonGroupContainer
extends HBoxContainer

@export_group("Prefabs")
## 分隔符按钮预制体
@export var seperate_button_prefab: PackedScene

@export_group("Nodes")
## 选项列表的父节点
@export var options_parent: Control
## 地址按钮组容器
@export var button_group: Container
## 地址按钮滚动容器
@export var button_group_scroll_container: ScrollContainer
## 按钮组的模式触发区
@export var button_group_mode_trigger_zone: Panel

signal trigger_mode_to_line_edit()
signal address_text_changed(new_text: String)

# 地址的字符串
var address_text := ""
# 按钮组变化时，需要scrollcontainer滚动到末端，但scrollcontainer检测子节点长度变化是个异步过程，需要缓存一个标记
var button_group_dirty := false

func _ready() -> void:
	# 信号链接
	button_group_mode_trigger_zone.gui_input.connect(_on_button_group_mode_trigger_zone_gui_input)
	button_group_scroll_container.gui_input.connect(_on_button_group_scroll_container_gui_input)
	var scroll_bar := button_group_scroll_container.get_h_scroll_bar()
	scroll_bar.changed.connect(_on_button_group_scroll_container_scrollbar_changed)

# 点击按钮面板空白地方时切换到输入框面板
func _on_button_group_scroll_container_gui_input(event: InputEvent) -> void:
	var button_event := event as InputEventMouseButton
	if button_event and button_event.button_index == 1 and button_event.pressed == false:
		trigger_mode_to_line_edit.emit()

# 点击按钮面板触发区时切换到输入框面板
func _on_button_group_mode_trigger_zone_gui_input(event: InputEvent) -> void:
	var button_event := event as InputEventMouseButton
	if button_event and button_event.button_index == 1 and button_event.pressed == false:
		trigger_mode_to_line_edit.emit()

# 当buttongroup变化时，将滚动容器滚动到末端
func _on_button_group_scroll_container_scrollbar_changed() -> void:
	if !button_group_dirty:
		return
	button_group_dirty = false
	var scroll_bar := button_group_scroll_container.get_h_scroll_bar()
	button_group_scroll_container.scroll_horizontal = ceili(scroll_bar.max_value)
	
# 当文字变化时更新按钮组
func _on_available_address_text_changed(new_text: String) -> void:
	address_text = new_text
	update_button_group()

# 更新按钮组
func update_button_group() -> void:
	# 清除按钮组
	var text := address_text
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
		if path_list[index].replacen(" ", "") == "": # 移除为空的地址
			path_list.remove_at(index)
	if path_list.size() == 0:
		trigger_mode_to_line_edit.emit()
		return
	# 根据地址片段生成地址按钮和分割按钮
	var button_path_list := []
	for path_segment in path_list:
		# 动态创建地址按钮，点击后将路径重置到当前按钮为止的路径
		button_path_list.push_back(path_segment)
		var button_path := "/".join(button_path_list)
		var path_button = Button.new() # 原生按钮即可
		path_button.text = path_segment
		path_button.button_up.connect(func():
			address_text_changed.emit(button_path)
		)
		button_group.add_child(path_button)
		# 实例化分割按钮，点击后显示该路径下的子路径
		var path_dir := DirAccess.open(button_path)
		var sub_directories := path_dir.get_directories()
		if sub_directories.size() == 0: # 无子路径的话不显示按钮
			continue
		var seperate_button := seperate_button_prefab.instantiate() as AddressLineEditSeperateButton
		seperate_button.options_parent = options_parent
		seperate_button.options = sub_directories
		seperate_button.item_selected.connect(func(_index: int, content: String):
			var selected_path := button_path + "/" + content
			address_text_changed.emit(selected_path)
		)
		button_group.add_child(seperate_button)
		button_group_dirty = true
