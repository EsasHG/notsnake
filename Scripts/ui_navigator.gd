extends Node

@onready var streamPlayer: AudioStreamPlayer = get_tree().root.find_child("UI_Back", true,false)
@onready var _mainGuiNode = get_tree().root.find_child("Gui", true, false)
var _ui_stack : Array[UI_Helper]

class UI_Helper:
	var control : Control
	var destroy_on_pop : bool = false
	var root: bool = false
	var callback : Callable = Callable()


func _ready() -> void:
	GameSettings.on_gameBegin.connect(_reset)
	GameSettings.on_mainMenuOpened.connect(_reset)
	process_mode = Node.PROCESS_MODE_ALWAYS

## Makes a new Control visible, and adds it to the top of the stack (aka it'll be the one hidden next time back() is called
## new_layer: the new control to open
## hide_previous: If true, the previous node's visibility will be set to hidden
## root: stops this node from being hidden or deleted when back() is called, as long as it's still valid
func open(new_layer:Control, hide_previous:bool = true, root:bool = false,  back_callback:Callable = Callable()) -> void:
	_cleanup()
	
	new_layer.visible = true
	if hide_previous && _ui_stack.size() > 0:
		_ui_stack.back().control.visible = false
	
	var newHelper : UI_Helper = UI_Helper.new()
	newHelper.control = new_layer
	newHelper.callback = back_callback
	newHelper.root = root
	_ui_stack.append(newHelper)


## Opens a new Control from a PackedScene, and adds it to the top of the stack (aka it'll be the one hidden next time back() is called
## Scenes opened with this function are automatically deleted when back() is called on them.
## new_layer: the PackedScene that contains the new Control to open
## hide_previous: If true, the previous node's visibility will be set to hidden
## root: stops this node from being hidden or deleted when back() is called, as long as it's still valid
func open_from_scene(new_layer:PackedScene, hide_previous:bool = true, root:bool = false, back_callback:Callable = Callable()) -> Node:
	_cleanup()
	
	var s : Control = new_layer.instantiate()
	s.visible = true
	var newHelper : UI_Helper = UI_Helper.new()
	newHelper.control = s
	newHelper.root = root
	newHelper.destroy_on_pop = true
	newHelper.callback = back_callback
	_mainGuiNode.add_child(s)
	
	if hide_previous && _ui_stack.size() > 0:
		_cleanup()
		_ui_stack.back().control.visible = false
	_ui_stack.append(newHelper)
	
	return s


func back() -> bool:
	var valid_removal = false
	if !_cleanup() && _ui_stack.size() > 0:
		if not _ui_stack.back().root:
			var move_from : UI_Helper = _ui_stack.pop_back()
			if move_from.callback.is_valid():
				move_from.callback.call()
			if move_from:
				move_from.control.visible = false
				if move_from.destroy_on_pop:
					move_from.control.queue_free()
				valid_removal = true
		if _ui_stack.size() > 0:
			_cleanup()
	return valid_removal


func _reset() -> void:
	_ui_stack.clear()


# returns true if something was invalid and removed
# kinda wanna try to never run into this... 
# but if it works it works, and it seems to work lmao
func _cleanup() -> bool: 
	var something_removed:bool = false
	while _ui_stack.size() > 0 && !is_instance_valid(_ui_stack.back().control):
		Logging.error("Some invalid node was removed from UINavigator!")
		_ui_stack.pop_back()
		something_removed = true
		
	if 	_ui_stack.size() > 0:
		_ui_stack.back().control.visible = true
	return something_removed


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Press"):
		var moved_back = back()
		if moved_back and streamPlayer:
			streamPlayer.play()	#is this ok?

func add_callable(callable:Callable) -> void:
	_ui_stack.back().callback = callable
