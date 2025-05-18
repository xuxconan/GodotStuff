@tool
extends Node

const EMPTY_OPTION_LABEL := "<空>"
const SELF_NAME := "BuildInIconSelector.gd"
const NAME_OF_UPDATE_TRIGGERER := "update_options"
const NAME_OF_PROPERTY_SELECTOR := "synchronize_property"
const NAME_OF_ICON_SELECTOR := "selected_icon"

var property_options := []
var selected_property_index := 0

var build_in_icon_options := []
var selected_icon_index := 0

var option_updating := false

# 触发属性更新
func trigger_property_update():
	notify_property_list_changed()
	
func get_property_option_label(category, property):
	return "[" + category + "] " + property

func get_build_in_icon_option_label(type, name):
	return "[" + type + "] " + name

# 将选择框的index锁定在数组范围内
func trim_property_selection(value):
	selected_property_index = clampi(value, 0, property_options.size() - 1)

# 将选择框的index锁定在数组范围内
func trim_icon_selection(value):
	selected_icon_index = clampi(value, 0, build_in_icon_options.size() - 1)

# 更新属性列表
func update_property_options():
	property_options = []
	var category := ""
	for prop in get_property_list():
		var prop_usage = prop["usage"]
		var prop_name = prop["name"]
		var prop_type = prop["type"]
		var prop_hint = prop.get("hint", 0)
		var prop_hint_str = prop["hint_string"]
		if prop_usage & PROPERTY_USAGE_CATEGORY:
			category = prop_name
		else:
			if category == SELF_NAME or prop_type != TYPE_OBJECT or prop_hint != PROPERTY_HINT_RESOURCE_TYPE:
				continue
			var accept_types = prop_hint_str.split(",")
			var is_accept_texture_2d := false
			for accept_type in accept_types:
				if ClassDB.is_parent_class(accept_type.strip_edges(), "Texture2D"):
					is_accept_texture_2d = true
					break
			if !is_accept_texture_2d:
				continue
			property_options.push_back({
				"category": category,
				"name": prop_name,
				"is_empty": false,
			})
	property_options.push_front({
		"category": "",
		"name": "",
		"is_empty": true,
	})
	trim_property_selection(selected_property_index)
	
# 更新图标列表
func update_build_in_icon_options():
	build_in_icon_options = []
	var theme := ThemeDB.get_default_theme()
	var icon_types := theme.get_icon_type_list()
	for icon_type in icon_types:
		var icon_names := theme.get_icon_list(icon_type)
		for icon_name in icon_names:
			var icon := theme.get_icon(icon_name, icon_type)
			build_in_icon_options.push_back({
				"type": icon_type,
				"name": icon_name,
				"icon": icon
			})
	build_in_icon_options.push_front({
		"type": "",
		"name": "",
		"icon": null
	})
	trim_icon_selection(selected_icon_index)

# 同步选中的图标到属性钟
func synchronize_icon_to_property():
	var property = property_options[selected_property_index]
	if property.is_empty:
		return
	var icon = build_in_icon_options[selected_icon_index].icon
	var category := ""
	for prop in get_property_list():
		var prop_usage = prop["usage"]
		var prop_name = prop["name"]
		if prop_usage & PROPERTY_USAGE_CATEGORY:
			category = prop_name
		else:
			if category == SELF_NAME or category != property.category or prop_name != property.name:
				continue
			set(prop_name, icon)
			
func _get_property_list() -> Array[Dictionary]:
	if !option_updating:
		option_updating = true
		update_property_options()
		update_build_in_icon_options()
		option_updating = false
	var prop_hint_str := ",".join(property_options.map(func (item):
		if item.is_empty:
			return EMPTY_OPTION_LABEL
		return get_property_option_label(item.category, item.name)
	))
	var icon_hint_str := ",".join(build_in_icon_options.map(func (item): 
		if !item.icon:
			return EMPTY_OPTION_LABEL
		return get_build_in_icon_option_label(item.type, item.name)
	))
	return [{
		"name": NAME_OF_UPDATE_TRIGGERER,
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
	},{
		"name": NAME_OF_PROPERTY_SELECTOR,
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": prop_hint_str,
	}, {
		"name": NAME_OF_ICON_SELECTOR,
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": icon_hint_str,
	}]

func _set(property: StringName, value) -> bool:
	if property == NAME_OF_UPDATE_TRIGGERER:
		if value:
			trigger_property_update()
		return true
	elif property == NAME_OF_PROPERTY_SELECTOR:
		trim_property_selection(value)
		synchronize_icon_to_property()
		return true
	elif property == NAME_OF_ICON_SELECTOR:
		trim_icon_selection(value)
		synchronize_icon_to_property()
		return true
	return false
	
func _get(property: StringName):
	if property == NAME_OF_UPDATE_TRIGGERER:
		return false
	elif property == NAME_OF_PROPERTY_SELECTOR:
		return selected_property_index
	elif property == NAME_OF_ICON_SELECTOR:
		return selected_icon_index
	return null
