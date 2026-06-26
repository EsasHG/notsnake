extends AudioStreamPlayer2D

@export var min_rest_time = 2.5
@export var max_rest_time = 4.0
@export var trees :Array[Node2D]
var countdown : Timer


func _ready() -> void:
	countdown = Timer.new()
	countdown.name = "BirdTimer"
	countdown.autostart = false
	countdown.one_shot = true
	countdown.timeout.connect(play_bird_sfx)
	GameSettings.on_gameOver.connect(countdown.stop)
	add_child.call_deferred(countdown)
	countdown.start.call_deferred(randf_range(min_rest_time,max_rest_time))


func play_bird_sfx() -> void:
	global_position = trees.pick_random().global_position
	play()
	countdown.start(randf_range(min_rest_time,max_rest_time))
	
