extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_gameOver.connect(stopMusic)

func stopMusic(won:bool):
	var music = find_child("BGMusic", true, false)
	music.stop()
	music.stream_paused = true
	var loseMusic = find_child("LoseMusic", true, false)
	loseMusic.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
