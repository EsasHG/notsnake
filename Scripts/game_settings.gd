extends Node

@export var currentScore : int = 0 
var highScore : int = 0

var sfxVol = 0
var musicVol = -15

var musicMuted : bool = false
var sfxMuted : bool = false

func _enter_tree() -> void:
	print_debug("Entered tree!")
	GodotPlayGameServices.initialize()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#PlayGamesSDK.initialize(this)
	if FileAccess.file_exists("user://savegame.save"):
		loadScore()	
	else:
		sfxMuted = false
		musicMuted = false
		
	if db_to_linear(GameSettings.musicVol) == 0:
		musicMuted = true
		
	if db_to_linear(GameSettings.sfxVol) == 0:
		sfxMuted = true
		
	call_deferred("connectToButtons")
	
func connectToButtons():
	var button : Button = get_tree().root.find_child("MusicMute", true, false)
	if(is_instance_valid(button)):
		button.toggled.connect(_on_music_mute_toggled)
		button.set_pressed_no_signal(musicMuted)
	setMusicVol(musicVol)
	
	button = get_tree().root.find_child("SFXMute", true, false)
	if(is_instance_valid(button)):
		button.toggled.connect(_on_sfx_mute_toggled)
		button.set_pressed_no_signal(sfxMuted)
	setSFXVol(sfxVol)
	
	SignalManager.on_pickup.connect(increaseScore)
	
func increaseScore():
	currentScore+=1
		

func saveScore():
	var saveFile = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	
	var saveDict = {"highScore" = highScore, "musicVol" = musicVol, sfxVol = sfxVol} 
	saveFile.store_line(JSON.stringify(saveDict))
	print_debug("Saved!")
	
	
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
		var node_data : Dictionary = json.data
		
		highScore = node_data["highScore"]
		
		if node_data.has("sfxVol"):
			sfxVol = node_data["sfxVol"]
		else:
			print_debug("Could not load SFX volume from save file!")
			
		if node_data.has("musicVol"):
			musicVol = node_data["musicVol"]
		else:
			print_debug("Could not load music volume from save file!")
			musicVol = -15
	print_debug("Finished loading")
		
func setSFXVol(in_vol : float):
	sfxVol = in_vol
	for audio : AudioStreamPlayer2D in get_tree().root.find_children("*", "AudioStreamPlayer2D", true, false):
		audio.volume_db = in_vol
	saveScore()

func setMusicVol(in_vol : float):
	musicVol = in_vol
	for audio : AudioStreamPlayer in get_tree().root.find_children("*", "AudioStreamPlayer", true, false):
		audio.volume_db = in_vol
	saveScore()

func _on_music_mute_toggled(toggled_on: bool) -> void:
	musicMuted = toggled_on
	var vol : float = -15
	if musicMuted: 
		vol = linear_to_db(0)
	setMusicVol(vol)

func _on_sfx_mute_toggled(toggled_on: bool) -> void:
	sfxMuted = toggled_on
	var vol : float = -15
	if sfxMuted: 
		vol = linear_to_db(0)
	setSFXVol(vol)
	
