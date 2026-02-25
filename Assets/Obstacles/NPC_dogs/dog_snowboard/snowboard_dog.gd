extends Area2D

@onready var player : Node2D = get_tree().root.find_child("PlayerDog", true, false)
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var distThreshold = 250
var scale_y : float
@export var flip_time = 0.2
var playerCrossedThreshold = false
var flipped = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale_y = scale.y
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if(player != null && global_position.distance_squared_to(player.global_position) < distThreshold* distThreshold):
		if(!playerCrossedThreshold):
			playerCrossedThreshold = true
			audio_stream_player_2d.play()
	elif(player != null):
		if(playerCrossedThreshold):
			playerCrossedThreshold = false
			audio_stream_player_2d.stop()
	elif(player == null):
		player = get_tree().root.find_child("PlayerDog", true, false)

		audio_stream_player_2d.stop()
	
	if global_rotation_degrees < -90 and not flipped:
		get_tree().create_tween().tween_property(self,"scale:y", -scale_y, flip_time)
		flipped = true
	elif global_rotation_degrees > -90 and flipped:
		get_tree().create_tween().tween_property(self,"scale:y", scale_y, flip_time)
		flipped = false
		
