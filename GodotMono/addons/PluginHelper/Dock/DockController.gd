tool
extends Control

#region resources
var PluginItem = preload("res://addons/PluginHelper/Components/PluginItem.tscn")
#endregion

#region private constants
const OnStatus = 1
const OffStatus = 0
#endregion

#region private variables
var switchBtn: MenuButton = null
var reloadBtn: Button = null
var refreshBtn: Button = null
var itemContainer: VBoxContainer = null

var items: Array = []
var pool: Array = []
var plugins: Array = []
#endregion

#region properties
var EditorInterfaceInst: EditorInterface
#endregion

#region listeners
func onSwitchChange(index):
	var optionId = switchBtn.get_popup().get_item_id(index)
	var enabled = optionId == OnStatus
	for item in items:
		item.Enabled = enabled
		
func onReloadBtnClick(): reload()
func onRefreshBtnClick():
	for i in range(items.size()):
		items[i].RefreshPlugin()
#endregion

#region logics
func reload():
	plugins.clear()
	
	# walk through plugin config files
	var dir = Directory.new()
	if dir.open("res://addons") == OK:
		dir.list_dir_begin(true)
		var dir_name = dir.get_next()
		while dir_name != "":
			if dir.current_is_dir():
				var pluginCfgFile = "res://addons/" + dir_name + "/plugin.cfg"
				if dir.file_exists(pluginCfgFile):
					var config = ConfigFile.new()
					if config.load(pluginCfgFile) == OK:
						var pluginName = config.get_value("plugin", "name")
						plugins.append(pluginName)
			dir_name = dir.get_next()
			
	# create items
	var pluginsSize = plugins.size()
	var itemsSize = items.size()
	for i in range(pluginsSize):
		var plugin = plugins[i]
		var item;
		if i < itemsSize: item = items[i]
		if item: item.get_parent().remove_child(item)
		if !item: item = pool.pop_back()
		if !item: item = PluginItem.instance()
		if i >= itemsSize: items.append(item)
		itemContainer.add_child(item)
		item.BindPlugin(plugin, EditorInterfaceInst)
	itemsSize = items.size()
	if pluginsSize >= itemsSize: return
	
	# put addition items into pool
	for i in range(itemsSize - pluginsSize):
		var item = items[i + pluginsSize]
		item.get_parent().remove_child(item)
	pool.append_array(items.slice(pluginsSize, itemsSize))
	items = items.slice(0, pluginsSize)
#endregion

#region lifecycle
func _ready():
	switchBtn = get_node("MainContainer/ButtonContainer/SwitchAllBox/SwitchAllBackground/SwitchAllDropdown") 
	var popup = switchBtn.get_popup()
	popup.clear()
	popup.add_item('Set All Off', OffStatus)
	popup.add_item('Set All On', OnStatus)
	popup.connect("index_pressed", self, "onSwitchChange")
	reloadBtn = get_node("MainContainer/ButtonContainer/ReloadAllBox/ReloadAllButton")
	reloadBtn.connect("button_down", self, "onReloadBtnClick")
	refreshBtn = get_node("MainContainer/ButtonContainer/RefreshAllBox/RefreshAllButton")
	refreshBtn.connect("button_down", self, "onRefreshBtnClick")
	itemContainer = get_node("MainContainer/PluginsContainer/ListContainer")
	items = itemContainer.get_children()
	reload()
#endregion
