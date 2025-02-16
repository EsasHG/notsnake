extends Area2D

@onready var player : Node2D = get_tree().root.find_child("PlayerDog", true, false)

@export var distThreshold = 250
var playerCrossedThreshold = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("default")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if(player != null && global_position.distance_squared_to(player.global_position) < distThreshold* distThreshold):
		if(!playerCrossedThreshold):
			playerCrossedThreshold = true
			$AnimatedSprite2D.play("angry")
			$AudioStreamPlayer2D.play()
	elif(player != null):
		if(playerCrossedThreshold):
			playerCrossedThreshold = false
			$AnimatedSprite2D.play("default")
			$AudioStreamPlayer2D.stop()
	elif(player == null):
		player = get_tree().root.find_child("PlayerDog", true, false)
		$AnimatedSprite2D.play("default")	
		$AudioStreamPlayer2D.stop()
