extends Node

signal on_pickup()
signal on_gameOver(won:bool)
signal on_gameBegin()
signal on_pickupSpawned(pickup:Area2D)
signal on_mainMenuOpened()
signal on_sfx_volume_changed(new_vol : float)
signal on_controls_changed(holdControls:bool)

@export var currentScore : int = 0 

@onready var gameOverScreen : PackedScene = preload("res://Scenes/GameOverScreen.tscn")
@onready var playerChar : PackedScene = preload("res://Scenes/PlayerDog.tscn")
@onready var pauseMenu : PackedScene = preload("res://Scenes/Menus/pause_menu.tscn")
@onready var bubbleScene : PackedScene = preload("res://Scenes/BubbleCutscene.tscn")
@onready var signInClient : PlayGamesSignInClient = get_tree().root.find_child("PlayGamesSignInClient", true, false)


var currentMap :Map
var highScores = {"Field":0, "Park": 0, "Square": 0, "Small":0, "Forest":0}
var sfxVol = linear_to_db(0.8)
var musicVol = linear_to_db(0.8)
var musicMuted : bool = false
var sfxMuted : bool = false
var userAuthenticated = false
var holdControls:bool = true
var pauseButton:Button
var achievementsCache: Array[PlayGamesAchievement]

var achievementsClient : PlayGamesAchievementsClient
var leaderboardsClient : PlayGamesLeaderboardsClient

var scoreBoard : PlayGamesLeaderboard
var leaderboardArray : Array[PlayGamesLeaderboard]
var currentWorld : Node2D
func _enter_tree() -> void:
	Logging.logMessage("GameSettings Entered tree!")
	if GodotPlayGameServices.initialize() == GodotPlayGameServices.PlayGamesPluginError.OK:
		Logging.logMessage("Godot play games services initialized successfully")
	else:
		Logging.error("Could not initialize godot play games services plugin!")
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#PlayGamesSDK.initialize(this)
	if FileAccess.file_exists("user://savegame.save"):
		loadScore()	
	else:
		sfxMuted = false
		musicMuted = false
	
	on_pickup.connect(increaseScore)
	on_gameOver.connect(gameOver)
	#on_gameBegin.connect(startGame)
	call_deferred("doDeferredSetup")	
	
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
	
	pauseButton = get_tree().root.find_child("PauseButton", true, false)
	if(is_instance_valid(pauseButton)):
		pauseButton.pressed.connect(_on_pause_pressed)
	else:
		Logging.error("Pause button not found in game settings!")
		
	if GodotPlayGameServices.android_plugin:
		if(signInClient):
			signInClient.user_authenticated.connect(_on_user_authenticated)
			signInClient.is_authenticated()
		else:
			Logging.error("No sign in client found!")
		
	else:
		Logging.error("Could not find Google Play Games Services plugin!")
		signInClient = null
		leaderboardsClient = null
		achievementsClient = null
		
		
func levelSelect():
	if(currentWorld != null):
		currentWorld.queue_free()
	var b = bubbleScene.instantiate()
	b.skipEntireCutscene = true
	b.levelSelect = true
	currentWorld = b
	get_tree().root.add_child(b)
	on_mainMenuOpened.emit()
		
func mainMenu():
	if(currentWorld != null):
		currentWorld.queue_free()
	var b = bubbleScene.instantiate()
	b.skipEntireCutscene = true
	b.levelSelect = false
	currentWorld = b
	get_tree().root.add_child(b)
	on_mainMenuOpened.emit()
	
func startGame():
	if(currentWorld != null):
		currentWorld.queue_free()
	else:
		Logging.logMessage("No existing world")
	currentWorld = currentMap.Scene.instantiate()
	get_tree().root.add_child(currentWorld)
	on_gameBegin.emit.call_deferred()
	pauseButton.visible = true
	
	
func gameOver(won:bool):
	if currentScore > highScores.get_or_add(currentMap.name,0):
		highScores[currentMap.name] = currentScore
		saveScore()
	
	if leaderboardsClient:
		Logging.logMessage("Trying to submit score: " + var_to_str(currentScore))
		var submitted : bool = false
		for board in leaderboardArray:
			if board.display_name == currentMap.name:
				scoreBoard = board
				Logging.logMessage("Leaderboard found. Submitting Score: " + var_to_str(currentScore))
				leaderboardsClient.submit_score(scoreBoard.leaderboard_id,currentScore)
				submitted = true
		if !submitted:
			Logging.error("Could not find a leaderboard with name "+ currentMap.name + "! Score was never submitted!")
	
	if(achievementsClient):
		_checkLevelAchievement(currentMap.name)
		if won:
			var ach:int = achievementsCache.find_custom(func(a:PlayGamesAchievement): a.achievement_id == "CgkIso_-xZsLEAIQBw")
			if achievementsCache[ach].state != PlayGamesAchievement.State.STATE_UNLOCKED:
				achievementsClient.unlock_achievement(achievementsCache[ach].achievement_id)
	var ui = gameOverScreen.instantiate()
	get_tree().root.find_child("Gui", true, false).add_child(ui)
	ui.GameOver(won)
	
	GameSettings.currentScore = 0
		
func increaseScore():
	currentScore+=1
		

func saveScore():
	Logging.logMessage("Saving!")
	var saveFile = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	
	var saveDict = {"highScores" = highScores, "musicVol" = db_to_linear(musicVol), "sfxVol" = db_to_linear(sfxVol), "musicMuted" = musicMuted, "sfxMuted" = sfxMuted, "controls" = holdControls} 
	saveFile.store_line(JSON.stringify(saveDict))
	Logging.logMessage("Saved!")
	
	
func loadScore():
	Logging.logMessage("Loading")
	if not FileAccess.file_exists("user://savegame.save"):
		Logging.logMessage("Error! Trying to load a non-existing save file!")	
			
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
			if(sfxMuted):
				setSFXVol(linear_to_db(0))
		else:
			Logging.error("Could not load SFX muted from save file!")
			sfxMuted = false
	
		if node_data.has("musicMuted"):
			musicMuted = node_data["musicMuted"]
			if(musicMuted):
				setMusicVol(linear_to_db(0))
		else:
			Logging.error("Could not load music muted from save file!")
			musicMuted = false

		if node_data.has("controls"):
			holdControls = node_data["controls"]
		else:
			holdControls = true
			
	Logging.logMessage("Finished loading")
		
func getCurrentMapHighScore():
	return highScores[currentMap.name]
		
func setSFXVol(in_vol : float):
	sfxVol = in_vol
	on_sfx_volume_changed.emit(in_vol)

func setMusicVol(in_vol : float):
	musicVol = in_vol
	for audio : AudioStreamPlayer in get_tree().root.find_children("*", "AudioStreamPlayer", true, false):
		audio.volume_db = in_vol

func setMusicMuted(muted:bool):
	musicMuted = muted
	var vol : float = linear_to_db(0.8)
	if musicMuted: 
		vol = linear_to_db(0)
	setMusicVol(vol)
	saveScore()
	
func setSFXMuted(muted:bool):
	sfxMuted = muted
	var vol : float = linear_to_db(0.8)
	if sfxMuted: 
		vol = linear_to_db(0)
	setSFXVol(vol)
	saveScore()
	
func setControls(hold:bool):
	holdControls = hold
	on_controls_changed.emit(holdControls)
	saveScore()
func _on_music_mute_toggled(toggled_on: bool) -> void:
	setMusicMuted(toggled_on)

func _on_sfx_mute_toggled(toggled_on: bool) -> void:
	setSFXMuted(toggled_on)

func _on_pause_pressed():
	Logging.logMessage("Pausing game")
	
	var pauseScreen = pauseMenu.instantiate()
	$"../Main/CanvasLayer/Gui".add_child(pauseScreen)
	
	if(not is_instance_valid(pauseButton)):
		pauseButton = get_tree().root.find_child("PauseButton",true,false)
	pauseButton.visible = false
				
	get_tree().paused = true

func showLeaderboard():
	if(leaderboardsClient):
		Logging.logMessage("Showing leaderboard " + scoreBoard.display_name)
		leaderboardsClient.show_leaderboard(scoreBoard.leaderboard_id)
	
func showAllLeaderboards():
	if(leaderboardsClient):
		Logging.logMessage("Showing all leaderboards")
		leaderboardsClient.show_all_leaderboards()

func showAchievements():
	if(achievementsClient):
		Logging.logMessage("Showing achievements")
		achievementsClient.show_achievements()

func _checkLevelAchievement(levelName:String):
	if achievementsClient and achievementsCache.size()>0 and highScores[levelName] >= 20:
		var achievementNum = achievementsCache.find_custom(func(a:PlayGamesAchievement): return a.achievement_name.contains(levelName))
		var ach: PlayGamesAchievement = achievementsCache[achievementNum]
		if ach.state != PlayGamesAchievement.State.STATE_UNLOCKED: 
			Logging.warn("Score is high enough for achievement! Unlocking achievement " + ach.achievement_name)
			achievementsClient.unlock_achievement(ach.achievement_id)
		else:
			Logging.logMessage("Score is high enough for achievement, and achievement is already unlocked! " + ach.achievement_name)


func _on_user_authenticated(is_authenticated: bool) -> void:
	if is_authenticated:
		#$Leaderboard.visible = true
		Logging.logMessage("Authenticated!")
		
		# If user was not authenticated before, setup leaderboard and achievements.
		if not userAuthenticated: 
			leaderboardsClient = get_tree().root.find_child("PlayGamesLeaderboardsClient", true, false)
			if leaderboardsClient:
				Logging.logMessage("Finding leaderboards!") 
				leaderboardsClient.all_leaderboards_loaded.connect(_all_leaderboards_loaded)
				leaderboardsClient.score_submitted.connect(_score_submitted)
				leaderboardsClient.score_loaded.connect(_on_player_score_loaded)
				leaderboardsClient.load_all_leaderboards(true)
			else:
				Logging.error("No leaderboards client found!")
				
			achievementsClient = get_tree().root.find_child("PlayGamesAchievementsClient", true, false)
			if(achievementsClient):
				achievementsClient.achievements_loaded.connect(_on_achievements_loaded)
				achievementsClient.load_achievements(true)
			else:
				Logging.error("No achievement client found!")
		
	else:
		#$Leaderboard.visible = false
		Logging.warn("User not authenticated!")

	userAuthenticated = is_authenticated

func _all_leaderboards_loaded(leaderboards: Array[PlayGamesLeaderboard]) -> void:
	Logging.logMessage("All leaderboards loaded!")
	if not leaderboards.size() == 0:
		leaderboardArray = leaderboards
		scoreBoard = leaderboardArray.front()
		
		for board in leaderboardArray:
			Logging.logMessage("Loading player score for leaderboard " + board.display_name)
			leaderboardsClient.load_player_score(board.leaderboard_id,PlayGamesLeaderboardVariant.TimeSpan.TIME_SPAN_ALL_TIME,PlayGamesLeaderboardVariant.Collection.COLLECTION_FRIENDS)
	else:
		Logging.error("No leaderboards found!")
	pass # Replace with function body.

func _on_player_score_loaded(leaderboard_id: String, score: PlayGamesLeaderboardScore):
	var leaderboard = leaderboardArray[leaderboardArray.find_custom(func(l:PlayGamesLeaderboard): return l.leaderboard_id == leaderboard_id)]
	Logging.logMessage("Score loaded for leaderboard " + leaderboard.display_name + ". Score: " + score.display_score)
	
	if highScores[leaderboard.display_name] < score.raw_score:
		Logging.warn("Found higher highscore from leaderboard! Overwriting locally saved score of" + str(highScores[leaderboard.display_name]) + " with " + str(score.raw_score))
		highScores[leaderboard.display_name] = score.raw_score
	elif highScores[leaderboard.display_name] > score.raw_score and score.raw_score > 0:
		Logging.warn("Found higher highscore in local save! submitting score of " + str(highScores[leaderboard.display_name]) + " to leaderboard " + leaderboard.display_name)
		leaderboardsClient.submit_score(leaderboard_id,highScores[leaderboard.display_name])
	_checkLevelAchievement(leaderboard.display_name)
		

func _score_submitted(is_submitted: bool, leaderboard_id: String) -> void:
	if is_submitted:
		Logging.logMessage("Score Submitted for leaderboard "+ leaderboard_id)
		if leaderboardsClient:
			Logging.logMessage("Loading player score for leaderboard " + leaderboard_id)
			leaderboardsClient.load_player_score(leaderboard_id,PlayGamesLeaderboardVariant.TimeSpan.TIME_SPAN_ALL_TIME, PlayGamesLeaderboardVariant.Collection.COLLECTION_PUBLIC)
	else: 
		Logging.error("Score not submitted for leaderboard " +  leaderboard_id)
	pass # Replace with function body.


func _on_achievements_loaded(achievements: Array[PlayGamesAchievement]) -> void:
	Logging.logMessage("Achievements loaded!")
	achievementsCache = achievements
	for key in highScores:
		_checkLevelAchievement(key)
			
