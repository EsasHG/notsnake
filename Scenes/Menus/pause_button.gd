extends AudioButton


func _ready() -> void:
	super()
	GameSettings.on_gameBegin.connect(_on_game_begin)
	GameSettings.on_gameOver.connect(_on_game_over)
	#var safe_area = DisplayServer.get_display_safe_area()
	#position.x = safe_area.size.x
	#position.y = safe_area.position.y

func _on_game_begin() -> void:
	UINavigator.open(self, false, true)


func _on_game_over() -> void:
	visible = false


func _on_pressed() -> void:
	GameSettings.pause_game()
