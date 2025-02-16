extends Node2D

var t1 = 0.15
var t2 = 0.4
@export var pointPos : Vector2

@onready var player = get_tree().root.find_child("PlayerDog", true, false)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var playerPos : Vector2 = player.global_position
	
	var q0 = playerPos.lerp(pointPos, min(t1, 1.0))
	var q1 = pointPos.lerp(global_position, min(t1, 1.0))
	$ComicBubbleSmall.global_position = q0.lerp(q1, min(t1, 1.0))
	
	var q1_2 = pointPos.lerp(global_position, min(t2, 1.0))
	$ComicBubbleMedium.global_position = q0.lerp(q1_2, min(t2, 1.0))
