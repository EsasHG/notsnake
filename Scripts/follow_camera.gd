extends Camera2D
var nodeToFollow:Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	GameSettings.on_gameBegin.connect(func(): nodeToFollow = get_tree().root.find_child("PlayerDog",true, false))
	
func ParentToDog():
	Logging.logMessage("Parenting to dog!")
	var dog = get_tree().root.find_child("PlayerDog",true, false)
	reparent(dog)
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,"position", Vector2(0,0), 0.5)
	


func _process(_delta: float) -> void:
	if nodeToFollow:
		global_position = lerp(global_position, nodeToFollow.global_position,0.1)
		
