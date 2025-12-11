extends Node

signal on_pickup()
signal on_gameOver()
signal on_gameBegin()
signal on_pickupSpawned(pickup:Area2D)
signal on_mainMenuOpened()
signal on_controls_changed(holdControls:bool)

@export var currentScore : int = 0 

enum GAME_MODE {LAST_DOG_STANDING, TIME, SCORE}

@onready var game_timer : Timer = Timer.new()
var round_time_seconds:int = 60 
var game_mode :GAME_MODE = GAME_MODE.LAST_DOG_STANDING
var lives = 1
var game_running:bool = false
const SCENE_TRANSITION = preload("res://Scenes/Menus/scene_transition.tscn")
@onready var gameOverScreen : PackedScene = preload("uid://ck7vl8h740cpk")
@onready var playerChar : PackedScene = preload("uid://bkjd5mneny7c1")
@onready var pauseMenu : PackedScene = preload("res://Scenes/Menus/pause_menu.tscn")
@onready var bubbleScene : PackedScene = preload("uid://3va5fhmx5hn4")

@onready var mainGuiNode = get_tree().root.find_child("Gui", true, false)

var player_spawners : Array[Node]

var players : Array[PlayerDog]
enum ViewportMode {PORTRAIT, LANDSCAPE}
var viewMode:ViewportMode = ViewportMode.LANDSCAPE

var currentMap :Map
var highScores = {"Field":0, "Park": 0, "Square": 0, "Small":0, "Forest":0}
var sfxVol = linear_to_db(0.8)
var musicVol = linear_to_db(0.8)
var musicMuted : bool = false
var sfxMuted : bool = false
var userAuthenticated = false
var holdControls:bool = true

var respawn_time = 3.0

var currentWorld : Node2D = null
var uiClickPlayer : AudioStreamPlayer

func _enter_tree() -> void:
	Logging.logMessage("GameSettings Entered tree!")
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadScore()	
	
	if not loadSettings():
		sfxMuted = false
		musicMuted = false
		setSFXMuted(sfxMuted)
		setMusicMuted(musicMuted)
	
	on_pickup.connect(increaseScore)
	on_gameOver.connect(gameOver)
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	call_deferred("doDeferredSetup")	
	game_timer.autostart = false
	game_timer.one_shot = true
	game_timer.wait_time = round_time_seconds
	game_timer.timeout.connect(func(): on_gameOver.emit())
	get_tree().root.add_child.call_deferred(game_timer)
	
	
func doDeferredSetup():
	if(currentWorld==null):
		currentWorld = get_tree().root.find_child("BubbleCutscene",true,false)
		
	
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
		

		
	var scene_transition:SceneTransition = get_tree().root.find_child("SceneTransition",true,false)
	get_tree().create_timer(1.5).timeout.connect(func(): scene_transition.transition_out())
	
func levelSelect():
	if(currentWorld != null):
		currentWorld.queue_free()
		currentWorld = null
	var b = bubbleScene.instantiate()
	b.skipEntireCutscene = true
	b.levelSelect = true
	currentWorld = b
	get_tree().root.add_child(b)
	game_running = false
	on_mainMenuOpened.emit()
	
	
func mainMenu():
	
	#TODO: Pause button dissapears when going back to the menu from a level, then back into a level
	#not sure there's anything here doing it, just needed to write it somewhere.
	if game_running:
		on_gameOver.emit()
	else:
		if(currentWorld != null):
			currentWorld.queue_free()
			currentWorld = null
		var b = bubbleScene.instantiate()
		b.skipEntireCutscene = true
		b.levelSelect = false
		currentWorld = b
		get_tree().root.add_child(b)
		on_mainMenuOpened.emit()
		game_running = false
		
	
func startGame():
	assert(!game_running)
	var transition : SceneTransition = _create_transition()
	transition.transition_in_finished.connect(_actually_start_game)
	get_tree().create_timer(1).timeout.connect(func(): 
		transition.transition_out()
		on_gameBegin.emit.call_deferred()
		)
	

func _actually_start_game():

	if currentWorld != null:
		currentWorld.queue_free()
		currentWorld = null
	else:
		Logging.logMessage("No existing world")
	currentWorld = currentMap.Scene.instantiate()
	get_tree().root.add_child(currentWorld)
	
	player_spawners = get_tree().root.find_children("PlayerStart_*","Node2D",true,false)
	
	var playerIndex = -1
	for id in GlobalInputMap.ControllerIds:
		playerIndex += 1
		if(id != -1):
			player_spawners[playerIndex].playerID = playerIndex
			player_spawners[playerIndex].spawn_player()
	Logging.logMessage("Starting game!")
	match game_mode:
		GAME_MODE.LAST_DOG_STANDING:
			Logging.logMessage("Last dog Standing!")
			for p in players:
				GlobalInputMap.Player_Lives[p.playerID] = lives
				GlobalInputMap.Player_Placement[p.playerID] = 1
		GAME_MODE.TIME:
			Logging.logMessage("Time: " + str(round_time_seconds))
			game_timer.start(round_time_seconds+1)
		GAME_MODE.SCORE:
			Logging.logMessage("Score! Round time: " + str(round_time_seconds))
			game_timer.start(round_time_seconds+1)
			for p in players:
				GlobalInputMap.Player_Score[p.playerID] = 0
	game_running = true	

func gameOver():
	if ! game_running: 
		return
	
	if currentWorld != null:
		currentWorld.queue_free()
		currentWorld = null
	if currentScore > highScores.get_or_add(currentMap.name,0):
		highScores[currentMap.name] = currentScore
		saveScore()
	
	var ui : GameOverScreen = gameOverScreen.instantiate()
	mainGuiNode.add_child(ui)
	
	Logging.logMessage("Game over!")
	ui.GameOver(players)
	players.clear()
	
	for s in player_spawners:
		s.stop_timer()
	player_spawners.clear()
	GlobalInputMap.Player_Lives.clear()
	GlobalInputMap.Player_Score.clear()
	GlobalInputMap.Player_Placement.clear()
	get_tree().create_timer(0.3).timeout.connect(ui.showButtons)
	currentScore = 0
	
	game_running = false
	
	
func increaseScore():
	currentScore+=1
		
func saveScore():
	Logging.logMessage("Saving!")
	var saveFile = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	
	var saveDict = {"highScores" = highScores} 
	saveFile.store_line(JSON.stringify(saveDict))
	Logging.logMessage("Saved!")
	
func saveSettings(): #TODO finish this
	pass
	Logging.logMessage("Saving!")
	var saveFile = FileAccess.open("user://settings.save", FileAccess.WRITE)
	
	var saveDict = {"musicVol" = db_to_linear(musicVol), "sfxVol" = db_to_linear(sfxVol), "musicMuted" = musicMuted, "sfxMuted" = sfxMuted, "controls" = holdControls} 
	saveFile.store_line(JSON.stringify(saveDict))
	Logging.logMessage("Saved!")
	
	
	
func loadScore() -> bool:
	Logging.logMessage("Loading")
	if not FileAccess.file_exists("user://savegame.save"):
		Logging.logMessage("Error! Trying to load a non-existing save file!")	
		return false
		
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_str = save_file.get_line()	
		var json = JSON.new()
		var parse_result = json.parse(json_str)
		if not parse_result == OK:
			Logging.error("JSON Parse Error: " + json.get_error_message() + " in " + json_str + " at line " + str(json.get_error_line()))

			continue
		var node_data : Dictionary = json.data
		
		if node_data.has("highScore"):
			highScores["Park"] = node_data["highScore"]
		elif node_data.has("highScores"):
			highScores = node_data["highScores"]
			
	Logging.logMessage("Finished loading high scores")
	return true
	
	
func loadSettings() -> bool:
	Logging.logMessage("Loading")
	var possibleFileNames: Array[String] = ["user://settings.save","user://savegame.save"]
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
			sfxVol = linear_to_db(node_data["sfxVol"])
		else:
			Logging.error("Could not load SFX volume from save file!")
			sfxVol = linear_to_db(0.8)
		if node_data.has("musicVol"):
			musicVol = linear_to_db(node_data["musicVol"])
		else:
			Logging.error("Could not load music volume from save file!")
			musicVol = linear_to_db(0.8)
			
		if node_data.has("sfxMuted"):
			sfxMuted = node_data["sfxMuted"]
			setSFXMuted(sfxMuted)
		else:
			Logging.error("Could not load SFX muted from save file!")
			sfxMuted = false
	
		if node_data.has("musicMuted"):
			musicMuted = node_data["musicMuted"]
			setMusicMuted(musicMuted)
		else:
			Logging.error("Could not load music muted from save file!")
			musicMuted = false

		if node_data.has("controls"):
			holdControls = node_data["controls"]
		else:
			holdControls = true
	Logging.logMessage("Finished loading settings")
	return true
			
		
func getCurrentMapHighScore():
	return highScores[currentMap.name]

func setMusicVol(in_vol : float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),in_vol)
	musicVol = in_vol
	
func setSFXVol(in_vol : float):
	sfxVol = in_vol
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),in_vol)

func setMusicMuted(muted:bool):
	Logging.logMessage("Setting music muted to " + str(muted))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"),muted)
	musicMuted = muted
	var vol : float = linear_to_db(0.8)
	if musicMuted: 
		vol = linear_to_db(0)
	setMusicVol(vol)
	saveSettings()
	
func setSFXMuted(muted:bool):
	Logging.logMessage("Setting sfx muted to " + str(muted))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"),muted)
	sfxMuted = muted
	var vol : float = linear_to_db(0.8)
	if sfxMuted: 
		vol = linear_to_db(0)
	setSFXVol(vol)
	saveSettings()
	
func setControls(hold:bool):
	holdControls = hold
	on_controls_changed.emit(holdControls)
	saveSettings()
	
func _create_transition() -> SceneTransition:
	var transition : SceneTransition = SCENE_TRANSITION.instantiate()
	mainGuiNode.add_child.call_deferred(transition)
	return transition
	
func _on_music_mute_toggled(toggled_on: bool) -> void:
	setMusicMuted(toggled_on)

func _on_sfx_mute_toggled(toggled_on: bool) -> void:
	setSFXMuted(toggled_on)

func _on_pause_pressed():
	Logging.logMessage("Pausing game")
	
	var pauseScreen = pauseMenu.instantiate()
	$"../Main/CanvasLayer/Gui".add_child(pauseScreen)
				
	get_tree().paused = true

func _on_viewport_size_changed():
	var viewportSize:Vector2 = get_viewport().size
	Logging.logMessage("Viewport size: " + str(get_viewport().size))
	if viewportSize.x > viewportSize.y:
		viewMode = ViewportMode.LANDSCAPE
	else:
		viewMode = ViewportMode.PORTRAIT
		
		
func player_lost(player : PlayerDog) -> void:
	players.erase(player)
	match game_mode:
		GAME_MODE.LAST_DOG_STANDING:
			if GlobalInputMap.Player_Lives.has(player.playerID):
				if GlobalInputMap.Player_Lives[player.playerID] > 1:
					GlobalInputMap.Player_Lives[player.playerID] -=1
					player_spawners[player.playerID].start_timer()
					players.erase(player)
				else:
					GlobalInputMap.Player_Placement[player.playerID] = players.size()+1
					if players.size() <= 1:
						on_gameOver.emit()
						players.clear()
		GAME_MODE.TIME:
			player_spawners[player.playerID].start_timer()
			players.erase(player)
			
	
