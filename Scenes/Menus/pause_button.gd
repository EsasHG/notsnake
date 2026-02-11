extends AudioButton


func _ready() -> void:
	super()
	GameSettings.on_gameBegin.connect(_on_game_begin)
	GameSettings.on_gameOver.connect(_on_game_over)
	

func _on_game_begin() -> void:
	UINavigator.open(self)


func _on_game_over() -> void:
	visible = false


func _on_pressed() -> void:
	GameSettings.pause_game()
