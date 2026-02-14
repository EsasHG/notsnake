extends ScrollContainer

@export var max_size: float = 570.0
@export var scrollbar_size_x : float = 32

var child : PanelContainer

func _ready() -> void:
	update_size()
	get_v_scroll_bar().custom_minimum_size.x = scrollbar_size_x
	child = get_child(0) as PanelContainer
	child.minimum_size_changed.connect(update_size)


func update_size() -> void:
	if not is_instance_valid(child):
		child = get_child(0) as Control
	var desired_size_y:float = child.size.y + 55
	Logging.logMessage("Desired size: " + str(desired_size_y))
	custom_minimum_size.y =  desired_size_y if desired_size_y < max_size else max_size
