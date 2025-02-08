extends Node

@export var currentScore : int = 0 
var highScore : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if FileAccess.file_exists("user://savegame.save"):
		loadScore()	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func saveScore():
	var saveFile = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	
	var saveDict = {"highScore" = highScore}
	saveFile.store_line(JSON.stringify(saveDict))
	
func loadScore():
	print_debug("Loading")
	if not FileAccess.file_exists("user://savegame.save"):
		print_debug("Error! Trying to load a non-existing save file!")	
			
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_str = save_file.get_line()	
		var json = JSON.new()
		var parse_result = json.parse(json_str)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_str, " at line ", json.get_error_line())
			continue
		var node_data = json.data
		highScore = node_data["highScore"]
