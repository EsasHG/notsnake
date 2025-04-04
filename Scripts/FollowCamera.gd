extends Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameSettings.on_gameBegin.connect(ParentToDog)
	
func ParentToDog():
	print_debug("Parenting to dog!")
	var dog = get_tree().root.find_child("PlayerDog",true, false)
	reparent(dog)
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,"position", Vector2(0,0), 0.5)
