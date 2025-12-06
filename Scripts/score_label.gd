extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameSettings.on_pickup.connect(SetScore)
	GameSettings.on_gameBegin.connect(func(): visible = true)
	GameSettings.on_gameOver.connect(func(_won:bool): visible = false)
	GameSettings.on_mainMenuOpened.connect(func(): visible = false)

func SetScore():
	#Ugly, just to make sure the score has updated.
	get_tree().process_frame.connect(func(): text = "Score: " + var_to_str(GameSettings.currentScore))
