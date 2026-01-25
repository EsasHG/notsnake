extends Label
var countdown : Timer
var current_time = 60
func _ready() -> void:
	countdown = Timer.new()
	countdown.autostart = false
	countdown.one_shot = false
	countdown.timeout.connect(count_down)
	visible = false
	GameSettings.on_gameBegin.connect(start_countdown)
	
	GameSettings.on_gameOver.connect(stop_countdown)
	
	add_child.call_deferred(countdown)


func start_countdown() -> void:
	if not GameSettings.game_timer.is_stopped():
		current_time = GameSettings.round_time_seconds
		text = str(current_time)
		modulate = Color.WHITE
		visible = true
		countdown.start(1)
	
	
func count_down():
	current_time -=1
		#stop_countdown(false)

	text = str(current_time)
	if current_time <= 0:
		countdown.stop()
	elif current_time <= 1:
		modulate = Color.CRIMSON
	elif current_time <= 3:
		modulate = Color.RED
	elif current_time <= 5:
		modulate = Color.CORAL
	elif current_time <= 10:
		modulate = Color.BISQUE 
		

func stop_countdown():
	countdown.stop()
	visible = false
	Logging.logMessage("Stopping countdown!")
