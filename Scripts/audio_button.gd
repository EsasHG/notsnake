extends Button

@onready var streamPlayer: AudioStreamPlayer = get_tree().root.find_child("UI_Click", true,false)

func _ready() -> void:
	pressed.connect(streamPlayer.play)
	
