extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameSettings.on_pickup.connect(_set_score)
	GameSettings.on_gameBegin.connect(_on_game_begin)
	GameSettings.on_gameOver.connect(func(): visible = false)
	GameSettings.on_mainMenuOpened.connect(func(): visible = false)


func _on_game_begin() -> void:
	visible = true
	_set_score()


func _set_score():
	#Ugly, just to make sure the score has updated.
	get_tree().process_frame.connect(func(): text = tr("SCORE") + " " + var_to_str(GameSettings.currentScore))
