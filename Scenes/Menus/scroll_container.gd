extends ScrollContainer

@export var do_size_update: bool = true
@export var max_size_landscape: float = 575.0
@export var max_size_portrait: float = 1160.0
@export var scrollbar_size_x : float = 32
@export var min_size_y : float

@export var padding : float = 0

@onready var child : PanelContainer = get_child(0) as PanelContainer

func _ready() -> void:
	var scrollbar = get_v_scroll_bar()
	scrollbar.theme_type_variation = "CustomScrollBar"
	scrollbar.custom_minimum_size.x = scrollbar_size_x
	scrollbar.scale.y = 0.9
	if do_size_update:
		update_size()
		child.resized.connect(update_size)
		GameSettings.on_viewportChanged.connect(update_size)
		GameSettings.adManager.admob.banner_ad_opened.connect(update_size)
		GameSettings.adManager.admob.banner_ad_closed.connect(update_size)
		GameSettings.on_banner_ad_changed.connect(update_size)
	
	
func update_size() -> void:
	#Logging.logMessage("min y: " + str(min_size_y))
	var max_y:float 
	if GameSettings.viewport_mode == GameSettings.VIEWPORT_MODE.PORTRAIT:
		max_y = max_size_portrait
	else:
		max_y = max_size_landscape
	#Logging.logMessage("max y: " + str(max_y))
	if GameSettings.adManager.banner_ad_showing:
		var banner_y = GameSettings.adManager.banner_ad_size.y
		max_y -= banner_y
	
	if not is_instance_valid(child):
		child = get_child(0) as Control
	var desired_size_y:float = child.size.y + padding
	if desired_size_y < min_size_y:
		desired_size_y = min_size_y 
	custom_minimum_size.y =  desired_size_y if desired_size_y < max_y else max_y
	#Logging.logMessage("custom min y: " + str(custom_minimum_size.y))
