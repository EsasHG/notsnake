extends MarginContainer
@export_category("Margins",)
	
@export_group("Portrait")
@export var top_margin_portrait: int = 40
@export var left_margin_portrait: int = 40
@export var bottom_margin_portrait: int = 40
@export var right_margin_portrait: int = 40

@export_group("Landscape") 
@export var top_margin_landscape: int = 40
@export var left_margin_landscape: int = 40
@export var bottom_margin_landscape: int = 40
@export var right_margin_landscape: int = 40

var prev_banner_height : int = 0
func _ready() -> void:
	_calculate_margins()
	GameSettings.on_viewportChanged.connect(_calculate_margins)
	GameSettings.on_banner_ad_changed.connect(_calculate_margins)
	#var screen = get_viewport_rect()
	#Logging.logMessage("Screen: " + str(screen))
	#Logging.logMessage("safe area: " + str(safe_area))
	#var close_margin:Vector2i = screen.position - Vector2(safe_area.size)
	#var far_margin:Vector2i = screen.size - Vector2(safe_area.size)
	#DisplayServer.get_display_cutouts()
	#Logging.logMessage("Close margin: " + str(safe_area.position))
	#Logging.logMessage("Far margin: " + str(far_margin))
	
	
func _calculate_margins() -> void:
	var safe_area = DisplayServer.get_display_safe_area()
	var top :int = 0
	var bot :int = 0
	var left :int = 0
	var right :int = 0
	if GameSettings.viewport_mode == GameSettings.VIEWPORT_MODE.PORTRAIT:
		top = top_margin_portrait
		bot = bottom_margin_portrait
		left = left_margin_portrait
		right = right_margin_portrait
	else:
		top = top_margin_landscape
		bot = bottom_margin_landscape
		left = left_margin_landscape
		right = right_margin_landscape

	var window_size = get_window().size
	
	if window_size.y >= safe_area.size.y:
		top += safe_area.position.y
		bot += window_size.y - (safe_area.position.y + safe_area.size.y)
	if window_size.x >= safe_area.size.x:
		left += safe_area.position.x
		right += window_size.x - (safe_area.position.x + safe_area.size.x)
	var ad_manager = GameSettings.adManager
	if ad_manager:
		var banner_height = ad_manager.banner_ad_size.y
		if banner_height > 0:
			bot += banner_height
			prev_banner_height = banner_height
		else:
			bot += prev_banner_height
			
			
	add_theme_constant_override("margin_top", top)
	add_theme_constant_override("margin_left", left)
	add_theme_constant_override("margin_bottom",bot)
	add_theme_constant_override("margin_right", right)
