extends Button

class_name AudioButton
@export var streamPlayerName = "UI_Click"
var streamPlayer: AudioStreamPlayer

func _ready() -> void:
	streamPlayer = get_tree().root.find_child(streamPlayerName, true,false)
	pressed.connect(streamPlayer.play)
	
