extends Camera2D
var nodeToFollow:Node2D
const PLAYER_SPAWN_NAME = "PlayerStart"
const PLAYER_DOG_NAME = "PlayerDog"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameSettings.game_mode == GameSettings.GAME_MODE.SINGLE_PLAYER:
		var player_spawner = get_tree().root.find_child(PLAYER_SPAWN_NAME,true,false)
		player_spawner.player_spawned.connect(set_follow_node)
	GameSettings.on_gameBegin.connect(find_dog)

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
		
