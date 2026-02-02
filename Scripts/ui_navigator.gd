extends Node


@onready var _mainGuiNode = get_tree().root.find_child("Gui", true, false)
var _ui_stack : Array[UI_Helper]

class UI_Helper:
	var control : Control
	var destroy_on_pop : bool = false


func _ready() -> void:
	GameSettings.on_gameBegin.connect(_reset)
	GameSettings.on_mainMenuOpened.connect(_reset)

func open(new_layer:Control, hide_previous:bool = true) -> void:
	_cleanup()
	
	if hide_previous && _ui_stack.size() > 0:
		_ui_stack.back().control.visible = false
	new_layer.visible = true
	
	var newHelper : UI_Helper = UI_Helper.new()
	newHelper.control = new_layer
	_ui_stack.append(newHelper)


func open_from_scene(new_layer:PackedScene, hide_previous:bool = true) -> Node:
	_cleanup()
	
	var s : Control = new_layer.instantiate()
	var newHelper : UI_Helper = UI_Helper.new()
	newHelper.control = s
	newHelper.destroy_on_pop = true
	if hide_previous && _ui_stack.size() > 0:
		_cleanup()
		_ui_stack.back().control.visible = false
	_ui_stack.append(newHelper)
	_mainGuiNode.add_child(s)
	
	s.visible = true
	return s

func back() -> void:
	if !_cleanup():
		var move_from : UI_Helper = _ui_stack.pop_back()
		if move_from:
			move_from.control.visible = false
			if move_from.destroy_on_pop:
				move_from.control.queue_free()
		if _ui_stack.size() > 0:
			_cleanup()


func _reset() -> void:
	_ui_stack.clear()


## returns true if something was invalid and removed
## kinda wanna try to never run into this... 
## but if it works it works, and it seems to work lmao
func _cleanup() -> bool: 
	var something_removed:bool = false
	while _ui_stack.size() > 0 && !is_instance_valid(_ui_stack.back().control):
		Logging.error("Some invalid node was removed from UINavigator!")
		_ui_stack.pop_back()
		something_removed = true
		
	if 	_ui_stack.size() > 0:
		_ui_stack.back().control.visible = true
	return something_removed
