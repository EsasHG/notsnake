extends Camera2D

var nodeToFollow:Node2D
var initial_limit_bottom

const PLAYER_SPAWN_NAME = "PlayerStart"
const PLAYER_DOG_NAME = "PlayerDog"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_limit_bottom = limit_bottom
	if GameSettings.game_mode == GameSettings.GAME_MODE.SINGLE_PLAYER:
		var player_spawner = get_tree().root.find_child(PLAYER_SPAWN_NAME,true,false)
		player_spawner.player_spawned.connect(set_follow_node)

	GameSettings.on_gameBegin.connect(find_dog)
	GameSettings.on_banner_ad_changed.connect(_set_limit_bottom)
	drag_horizontal_enabled = true
	drag_vertical_enabled = true
	drag_left_margin = 0.2
	drag_top_margin = 0.2
	drag_right_margin = 0.2
	drag_bottom_margin = 0.2
	
	_set_limit_bottom()



func _set_limit_bottom() -> void:
	if GameSettings.adManager and GameSettings.adManager.banner_ad_showing:
		limit_bottom = initial_limit_bottom + GameSettings.adManager.banner_ad_size.y
		var landscape = GameSettings.viewport_mode == GameSettings.VIEWPORT_MODE.LANDSCAPE
		drag_bottom_margin = 0.1 if landscape else 0.2
		drag_top_margin = 0.3 if landscape else 0.2
	else:
		limit_bottom = initial_limit_bottom
		drag_bottom_margin = 0.2
		drag_top_margin = 0.2


func set_follow_node(node_to_follow : Node2D) -> void:
	nodeToFollow = node_to_follow


func find_dog() -> void:
	nodeToFollow = get_tree().root.find_child(PLAYER_DOG_NAME,true, false)
	pass


func ParentToDog():
	Logging.logMessage("Parenting to dog!")
	var dog = get_tree().root.find_child(PLAYER_DOG_NAME,true, false)
	reparent(dog)
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,"position", Vector2(0,0), 0.5)


func _process(_delta: float) -> void:
	if nodeToFollow:
		global_position = lerp(global_position, nodeToFollow.global_position,0.1)
