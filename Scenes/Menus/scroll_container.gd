extends ScrollContainer

@export var max_size_landscape: float = 575.0
@export var max_size_portrait: float = 1160.0
@export var scrollbar_size_x : float = 32
@export var min_size_y : float
@export var padding : float = 100

@onready var child : PanelContainer = get_child(0) as PanelContainer

func _ready() -> void:
	update_size()
	var scrollbar = get_v_scroll_bar()
	scrollbar.theme_type_variation = "CustomScrollBar"
	scrollbar.custom_minimum_size.x = scrollbar_size_x
	scrollbar.scale.y = 0.9
	child.resized.connect(update_size)
	GameSettings.on_viewportChanged.connect(update_size)
	GameSettings.on_banner_ad_changed
	
func update_size() -> void:
	#Logging.logMessage("min y: " + str(min_size_y))
	var max_y:float 
	if GameSettings.viewport_mode == GameSettings.VIEWPORT_MODE.PORTRAIT:
		max_y = max_size_portrait
	else:
		max_y = max_size_landscape
	#Logging.logMessage("max y: " + str(max_y))
	
	if not is_instance_valid(child):
		child = get_child(0) as Control
	var desired_size_y:float = child.size.y + padding
	if desired_size_y < min_size_y:
		desired_size_y = min_size_y 
	custom_minimum_size.y =  desired_size_y if desired_size_y < max_y else max_y
	#Logging.logMessage("custom min y: " + str(custom_minimum_size.y))
