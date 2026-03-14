extends AudioStreamPlayer

@export var min_rest_time = 2.5
@export var max_rest_time = 4.0

var countdown : Timer


func _ready() -> void:
	countdown = Timer.new()
	countdown.autostart = false
	countdown.one_shot = true
	countdown.timeout.connect(play_bird_sfx)
	GameSettings.on_gameOver.connect(countdown.stop)
	add_child.call_deferred(countdown)
	countdown.start.call_deferred(randf_range(min_rest_time,max_rest_time))


func play_bird_sfx() -> void:
	play()
	countdown.start(randf_range(min_rest_time,max_rest_time))
	
