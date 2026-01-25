extends Node


@onready var _mainGuiNode = get_tree().root.find_child("Gui", true, false)
var _ui_stack : Array[UI_Helper]

class UI_Helper:
	var control : Control
	var destroy_on_pop : bool = false

func _ready() -> void:
	GameSettings.on_gameBegin.connect(_reset)
	
func open(new_layer:Control, hide_previous:bool = true) -> void:
	
	if hide_previous && _ui_stack.size() > 0:
		_ui_stack.back().control.visible = false
	new_layer.visible = true
	
	var newHelper : UI_Helper = UI_Helper.new()
	newHelper.control = new_layer
	_ui_stack.append(newHelper)

func open_from_scene(new_layer:PackedScene, hide_previous:bool = true) -> void:
	var s : Control = new_layer.instantiate()
	_mainGuiNode.add_child(s)
	var newHelper : UI_Helper = UI_Helper.new()
	newHelper.control = s
	newHelper.destroy_on_pop = true
	if hide_previous && _ui_stack.size() > 0:
		_ui_stack.back().control.visible = false
	_ui_stack.append(newHelper)
	s.visible = true

func back() -> void:
	var move_from :UI_Helper = _ui_stack.pop_back()
	move_from.control.visible = false
	if move_from.destroy_on_pop:
		move_from.control.queue_free()
	if _ui_stack.size() > 0:
		_ui_stack.back().control.visible = true

func _reset() -> void:
	_ui_stack.clear()
