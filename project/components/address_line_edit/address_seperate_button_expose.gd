## 分割按钮的暴露属性类
class_name AddressSeperateButtonExpose
extends Node

## 选项列表挂载的父节点
@export var options_parent: Control
## 选项列表相对于按钮的偏移
@export var options_offset := Vector2(0.0, 5.0)
## 选项列表数据
@export var options := []

## 选项被选中时的信号
signal item_selected(index: int, content: String)
	
func _ready() -> void:
	# 调用一下以消除未使用警告
	item_selected.get_name()