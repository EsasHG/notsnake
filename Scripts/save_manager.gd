extends Node

@onready var snapshotClient : PlayGamesSnapshotsClient = get_tree().root.find_child("PlayGamesSnapshotsClient", true, false)

const SETTINGS_FILE = "settings.save"
const SCORES_FILE = "savegame.save"
const UNLOCKS_FILE = "unlocks.save"
func _ready() -> void:
	pass#snapshotClient.load_game(SETTINGS_FILE)

func save_settings() -> void:
	Logging.logMessage("Saving settings!")
	var saveFile = FileAccess.open("user://" + SETTINGS_FILE, FileAccess.WRITE)
	
	var saveDict = {
			"musicVol" = db_to_linear(GameSettings.musicVol), 
			"sfxVol" = db_to_linear(GameSettings.sfxVol), 
			"musicMuted" = GameSettings.musicMuted, 
			"sfxMuted" = GameSettings.sfxMuted, 
			"controls" = GlobalInputMap.Player_Controls_Selected[0],
			"language" = GameSettings.language,
			"dogColor" = GlobalInputMap.player_colors[0].to_html(),
			"hat" = GlobalInputMap.Player_Hats_Selected[0],
			"times_crashed" = GameSettings.times_crashed,
			} 
			
	saveFile.store_line(JSON.stringify(saveDict))
	Logging.logMessage("Settings saved!")
	pass
	

func load_settings() -> bool:
	Logging.logMessage("Loading settings")
	var possibleFileNames: Array[String] = ["user://" + SETTINGS_FILE,"user://" + SCORES_FILE]
	var fileName:String = ""
	
	for possibleName:String in possibleFileNames:
		if FileAccess.file_exists(possibleName):
			fileName = possibleName
			break
			
	if fileName.is_empty():
		Logging.warn("Could not find a settings file!")
		return false
		
	var save_file = FileAccess.open(fileName, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_str = save_file.get_line()	
		var json = JSON.new()
		var parse_result = json.parse(json_str)
		if not parse_result == OK:
			Logging.error("JSON Parse Error: " + json.get_error_message() + " in " + json_str + " at line " + str(json.get_error_line()))

			continue
		var node_data : Dictionary = json.data
		
		if node_data.has("sfxVol"):
			GameSettings.sfxVol = linear_to_db(node_data["sfxVol"])
		else:
			Logging.error("Could not load SFX volume from save file!")
			GameSettings.sfxVol = linear_to_db(0.8)
			
		if node_data.has("musicVol"):
			GameSettings.musicVol = linear_to_db(node_data["musicVol"])
		else:
			Logging.error("Could not load music volume from save file!")
			GameSettings.musicVol = linear_to_db(0.8)
			
		if node_data.has("sfxMuted"):
			GameSettings.sfxMuted = node_data["sfxMuted"]
		else:
			Logging.error("Could not load SFX muted from save file!")
			GameSettings.sfxMuted = false
		GameSettings.setSFXMuted(GameSettings.sfxMuted)
	
		if node_data.has("musicMuted"):
			GameSettings.musicMuted = node_data["musicMuted"]
		else:
			Logging.error("Could not load music muted from save file!")
			GameSettings.musicMuted = false
		GameSettings.setMusicMuted(GameSettings.musicMuted)
		
		if node_data.has("controls"):
			GameSettings.setControls(node_data["controls"])
		else:
			GameSettings.setControls(true)
			
		if node_data.has("language"):
			GameSettings.language = node_data["language"]
			
		if node_data.has("dogColor"):
			GlobalInputMap.player_colors[0] = Color(node_data["dogColor"])
			
		if node_data.has("hat"):
			GlobalInputMap.Player_Hats_Selected[0] = node_data["hat"]
			GameSettings.on_dogHatChanged.emit(node_data["hat"])
		else: 
			GlobalInputMap.Player_Hats_Selected[0] = "NONE"
			
		if node_data.has("times_crashed"):
			GameSettings.times_crashed = node_data["times_crashed"]
			
	if GameSettings.language == "automatic":
		var preferred_language = OS.get_locale_language()
		TranslationServer.set_locale(preferred_language)
	else:
		TranslationServer.set_locale(GameSettings.language)
		
	Logging.logMessage("Finished loading settings")
	return true
	

func save_score() -> void:
	Logging.logMessage("Saving high scores!")
	var saveFile = FileAccess.open("user://" + SCORES_FILE, FileAccess.WRITE)
	
	var saveDict = {"highScores" = GameSettings.highScores} 
	saveFile.store_line(JSON.stringify(saveDict))
	Logging.logMessage("Saved!")


func load_score() -> bool:
	Logging.logMessage("Loading high scores")
	if not FileAccess.file_exists("user://" + SCORES_FILE):
		Logging.logMessage("Error! Trying to load a non-existing save file!")	
		return false
		
	var save_file = FileAccess.open("user://" + SCORES_FILE, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_str = save_file.get_line()	
		var json = JSON.new()
		var parse_result = json.parse(json_str)
		if not parse_result == OK:
			Logging.error("JSON Parse Error: " + json.get_error_message() + " in " + json_str + " at line " + str(json.get_error_line()))

			continue
		var node_data : Dictionary = json.data
		
		if node_data.has("highScore"):
			GameSettings.highScores["Park"] = node_data["highScore"]
		elif node_data.has("highScores"):
			GameSettings.highScores = node_data["highScores"]
			
	Logging.logMessage("Finished loading high scores")
	return true


func save_unlocks():
	Logging.logMessage("Saving unlocks!")
	var saveFile = FileAccess.open("user://" + UNLOCKS_FILE, FileAccess.WRITE)
	
	##Find unlocked maps
	var unlocked_maps :Array[String]
	for map: String in GlobalInputMap.Maps:
		if GlobalInputMap.Maps[map].unlocked:
			unlocked_maps.append(map)
			
				
	##Find unlocked hats:
	var unlocked_hats : Array[String]
	for hat: String in GlobalInputMap.Player_Hats:
		if GlobalInputMap.Player_Hats[hat].unlocked:
			unlocked_hats.append(hat)
	var saveDict = {
			"unlocked_maps" = unlocked_maps,
			"unlocked_hats" = unlocked_hats,
			} 
			
	saveFile.store_line(JSON.stringify(saveDict))
	Logging.logMessage("Saved!")
	pass


func load_unlocks():
	Logging.logMessage("Loading unlocks")
	if not FileAccess.file_exists("user://" + UNLOCKS_FILE):
		Logging.logMessage("Error! Trying to load a non-existing save file!")	
		return false
		
	var save_file = FileAccess.open("user://" + UNLOCKS_FILE, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_str = save_file.get_line()	
		var json = JSON.new()
		var parse_result = json.parse(json_str)
		if not parse_result == OK:
			Logging.error("JSON Parse Error: " + json.get_error_message() + " in " + json_str + " at line " + str(json.get_error_line()))
			continue
		var node_data : Dictionary = json.data
		
		if node_data.has("unlocked_maps"):
			var unlocked_maps : Array = node_data["unlocked_maps"]
			for map in unlocked_maps:
				GlobalInputMap.Maps[map].unlocked = true
		
		if node_data.has("unlocked_hats"):
			var unlocked_hats : Array = node_data["unlocked_hats"]
			for hat in unlocked_hats:
				GlobalInputMap.Player_Hats[hat].unlocked = true
			
	Logging.logMessage("Finished loading unlocks")
	return true
