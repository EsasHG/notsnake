extends Area2D

@onready var player : Node2D = get_tree().root.find_child("PlayerDog", true, false)
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var distThreshold = 250
var playerCrossedThreshold = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if(player != null && global_position.distance_squared_to(player.global_position) < distThreshold* distThreshold):
		if(!playerCrossedThreshold):
			playerCrossedThreshold = true
			$AnimatedSprite2D.play("angry")
			audio_stream_player_2d.play()
	elif(player != null):
		if(playerCrossedThreshold):
			playerCrossedThreshold = false
			$AnimatedSprite2D.play("default")
			audio_stream_player_2d.stop()
	elif(player == null):
		player = get_tree().root.find_child("PlayerDog", true, false)
		$AnimatedSprite2D.play("default")	
		audio_stream_player_2d.stop()
