tool
extends Control

#region private variables
var switchBtn: CheckButton
var refreshBtn: Button
var nameLabel: Label
var loadPanel: Panel

var pluginName: String = ""
var editorInterfaceInst: EditorInterface = null

var recheckCountdown = 1
#endregion

#region properties
var Loading: bool = false setget setLoading, getLoading
var loading: bool = false

func setLoading(value):
	loading = value
	refreshUi()
	
func getLoading():
	return loading

var Enabled: bool = true setget setEnabled, getEnabled
var enabled: bool = true

func setEnabled(value):
	if !allowEnable(): return
	enabled = value
	editorInterfaceInst.set_plugin_enabled(pluginName, value)
	print("插件", pluginName, "开启" if editorInterfaceInst.is_plugin_enabled(pluginName) else "关闭")
	refreshUi()
	
func getEnabled():
	return enabled
#endregion

#region public functions
func BindPlugin(pName: String, eInterfaceInst: EditorInterface):
	pluginName = pName
	editorInterfaceInst = eInterfaceInst
	enabled = editorInterfaceInst.is_plugin_enabled(pluginName)
	print("插件", pluginName, "开启" if enabled else "关闭")
	refreshUi()
	 
func RefreshPlugin(): refreshPlugin()
#endregion

#region listeners
func onEnableSwitchPressed(): setEnabled(switchBtn.pressed)
func onRefreshButtonClicked(): refreshPlugin()
#endregion
	
#region logics
func allowEnable():
	return pluginName && pluginName != "PluginHelper"
	
func allowRefresh():
	return enabled && pluginName && pluginName != "PluginHelper"

func refreshUi():
	switchBtn.disabled = !allowEnable()
	switchBtn.pressed = enabled
	refreshBtn.disabled = !allowRefresh()
	nameLabel.text = pluginName
	loadPanel.visible = loading

func refreshPlugin():
	if !allowRefresh() || !editorInterfaceInst || loading: return
	setLoading(true)
	setEnabled(false)
	var sleep = 1 + randf()
	yield (get_tree().create_timer(sleep), "timeout")
	setEnabled(true)
	setLoading(false)
#endregion

#region lifecycle
func _ready():
	switchBtn = get_node("HBoxContainer/EnableBox/EnableSwitch")
	switchBtn.connect("pressed", self, "onEnableSwitchPressed")
	refreshBtn = get_node("HBoxContainer/RefreshBox/RefreshButton")
	refreshBtn.connect("button_down", self, "onRefreshButtonClicked")
	nameLabel = get_node("HBoxContainer/NameBox/PluginName")
	loadPanel = get_node("Loading")
	refreshUi()
	
func _process(delta):
	if !pluginName: return
	recheckCountdown -= delta
	if recheckCountdown <= 0:
		recheckCountdown = 1
		var actualEnabled = editorInterfaceInst.is_plugin_enabled(pluginName)
		if actualEnabled == enabled: return
		setEnabled(actualEnabled)
#endregion
