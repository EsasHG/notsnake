@tool
extends EditorInspectorPlugin
var preview_scene = preload("res://addons/SkinViewerPlugin/skin_preview.tscn")


func _can_handle(object: Object) -> bool:
	return object is DogSkin	


func _parse_begin(object: Object) -> void:
	var preview_instance = preview_scene.instantiate()
	add_custom_control(preview_instance)
	if preview_instance.has_method("setup_preview"):
		preview_instance.setup_preview(object)
