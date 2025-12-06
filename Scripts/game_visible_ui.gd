extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	GameSettings.on_gameBegin.connect(func(): visible = true)
	GameSettings.on_gameOver.connect(func(_won:bool): visible = false)
	GameSettings.on_mainMenuOpened.connect(func(): visible = false)
