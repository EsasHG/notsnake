extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_gameOver.connect(stopMusic)

func stopMusic(_won:bool):
	var music = find_child("BGMusic", true, false)
	music.stop()
	music.stream_paused = true
	var loseMusic = find_child("LoseMusic", true, false)
	loseMusic.play()
