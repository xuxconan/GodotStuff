class_name AddressLineEditLineEditContainer
extends HBoxContainer

@export_group("Nodes")
## 地址输入组件
@export var line_edit: LineEdit

signal line_edit_focus_exited()
signal line_edit_text_changed(new_text: String)
signal line_edit_text_submitted(new_text: String)

# 历史列表
var history := []

func _ready() -> void:
	# 信号链接
	line_edit.text_changed.connect(_on_line_edit_text_changed)
	line_edit.focus_exited.connect(_on_line_edit_focus_exited)
	line_edit.text_submitted.connect(_on_line_edit_text_submitted)

# 输入框丢失焦点时切换到按钮面板
func _on_line_edit_focus_exited() -> void:
	line_edit_text_changed.emit()

# 当文字改变时同步到外部
func _on_line_edit_text_changed(new_text: String) -> void:
	line_edit_focus_exited.emit(new_text)

# 输入框按下回车时切换到按钮面板
func _on_line_edit_text_submitted(new_text: String) -> void:
	line_edit_text_submitted.emit(new_text)

# 当占位字符串变化时同步占位字符
func _on_placeholder_changed(new_text: String) -> void:
	line_edit.placeholder_text = new_text
	
# 当文字变化时同步文字
func _on_available_address_text_changed(new_text: String) -> void:
	line_edit.text = new_text
	
# 让输入框获取焦点
func _on_request_line_edit_to_grab_focus() -> void:
	line_edit.grab_focus()