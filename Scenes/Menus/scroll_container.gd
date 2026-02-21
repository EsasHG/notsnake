extends ScrollContainer

@export var max_size_landscape: float = 575.0
@export var max_size_portrait: float = 1160.0
@export var scrollbar_size_x : float = 32
@export var padding : float = 100

var child : PanelContainer

func _ready() -> void:
	update_size()
	var scrollbar = get_v_scroll_bar()
	scrollbar.theme_type_variation = "CustomScrollBar"
	scrollbar.custom_minimum_size.x = scrollbar_size_x
	scrollbar.scale.y = 0.9
	child = get_child(0) as PanelContainer
	child.minimum_size_changed.connect(update_size)
	get_viewport().size_changed.connect(_on_viewport_changed)
	
	
func update_size() -> void:
	var max_y:float 
	if GameSettings.viewport_mode == GameSettings.VIEWPORT_MODE.PORTRAIT:
		max_y = max_size_portrait
	else:
		max_y = max_size_landscape
			
	if not is_instance_valid(child):
		child = get_child(0) as Control
	var desired_size_y:float = child.size.y + padding
	custom_minimum_size.y =  desired_size_y if desired_size_y < max_y else max_y


func _on_viewport_changed() -> void:
	# Deferred to make sure GameSettings.viewport_mode is updated
	update_size.call_deferred()
