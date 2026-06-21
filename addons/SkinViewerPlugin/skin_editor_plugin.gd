@tool
extends EditorPlugin
const MyInspectorPlugin = preload("res://addons/SkinViewerPlugin/skin_inspector_plugin.gd")
var inspector_plugin = MyInspectorPlugin.new()


func _enter_tree() -> void:
	add_inspector_plugin(inspector_plugin)
	

func _exit_tree() -> void:
	if inspector_plugin:
		remove_inspector_plugin(inspector_plugin)
