## 地址输入栏的暴露属性类
class_name AddressLineEditExpose
extends Control

## 初始化地址文字
@export var text := ""
## 占位文字
@export var placeholder_text := "请输入地址"
## 历史列表
@export var history := []

## 有效地址变更时的信号
signal address_changed(path: String)
	
func _ready() -> void:
	# 调用一下以消除未使用警告
	address_changed.get_name()