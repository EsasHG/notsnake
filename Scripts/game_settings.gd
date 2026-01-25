extends Node

signal on_pickup()
signal on_gameOver()
signal on_gameBegin()
signal on_pickupSpawned(pickup:Area2D)
signal on_mainMenuOpened()
signal on_controls_changed(holdControls:bool)

const BILLING_MANAGER = preload("uid://di83hh7jce01j")
const AD_MANAGER = preload("uid://ck01dnrayeqyd")

@export var currentScore : int = 0 

enum GAME_MODE {LAST_DOG_STANDING, TIME, SCORE, SINGLE_PLAYER}
#var game_mode :GAME_MODE = GAME_MODE.LAST_DOG_STANDING
var game_mode :GAME_MODE = GAME_MODE.SINGLE_PLAYER

@onready var game_timer : Timer = Timer.new()
var round_time_seconds:int = 60 
var lives = 1
var game_running:bool = false

const SCENE_TRANSITION = preload("uid://gsu5a1hu0rjf")
const GAME_OVER_SCREEN = preload("uid://ck7vl8h740cpk")
const ARENA_GAME_OVER_SCREEN = preload("uid://u1gfn45v12yd")

const PAUSE_MENU = preload("uid://d0eb6heqgmexf")
const BUBBLE_CUTSCENE = preload("uid://3va5fhmx5hn4")

@onready var signInClient : PlayGamesSignInClient = get_tree().root.find_child("PlayGamesSignInClient", true, false)
@onready var mainGuiNode = get_tree().root.find_child("Gui", true, false)
var adManager : AdManager = null
var billingManager : BillingManager = null

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
var pauseButton:Button

var achievementsClient : PlayGamesAchievementsClient = null
var leaderboardsClient : PlayGamesLeaderboardsClient = null
var scoreBoard : PlayGamesLeaderboard
var leaderboardArray : Array[PlayGamesLeaderboard]
var achievementsCache: Array[PlayGamesAchievement]

var currentWorld : Node2D = null

func _enter_tree() -> void:
	Logging.logMessage("GameSettings Entered tree!")
	if OS.has_feature("mobile"):
		if GodotPlayGameServices.initialize() == GodotPlayGameServices.PlayGamesPluginError.OK:
			Logging.logMessage("Godot play games services initialized successfully")
		else:
			Logging.error("Could not initialize godot play games services plugin!")
		game_mode = GAME_MODE.SINGLE_PLAYER
		
func _ready() -> void:
	loadScore()	
	
	if not loadSettings():
		sfxMuted = false
		musicMuted = false
		setSFXMuted(sfxMuted)
		setMusicMuted(musicMuted)
	
	on_pickup.connect(increaseScore)
	on_gameOver.connect(game_over)
	on_gameBegin.connect(func(): 
		game_running = true	
		)
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	call_deferred("_do_deferred_setup")	
	game_timer.autostart = false
	game_timer.one_shot = true
	game_timer.wait_time = round_time_seconds
	game_timer.timeout.connect(func(): on_gameOver.emit())
	get_tree().root.add_child.call_deferred(game_timer)
	
	
func _do_deferred_setup():
	if(currentWorld == null):
		currentWorld = get_tree().root.find_child("BubbleCutscene",true,false)
	if OS.has_feature("mobile"):
		adManager = get_tree().root.find_child("AdManager",true,false)#AD_MANAGER.instantiate()
		
		billingManager = BILLING_MANAGER.instantiate()
		billingManager.loading_finished.connect(_on_billing_manager_loading_finished)
		get_tree().root.find_child("Gui",true,false).call_deferred("add_child", billingManager)
		
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
		
	var scene_transition:SceneTransition = get_tree().root.find_child("SceneTransition",true,false)
	get_tree().create_timer(1.5).timeout.connect(func(): scene_transition.transition_out())


func levelSelect():
	if(currentWorld != null):
		currentWorld.queue_free()
		currentWorld = null
	var b = BUBBLE_CUTSCENE.instantiate()
	b.skipEntireCutscene = true
	b.levelSelect = true
	currentWorld = b
	get_tree().root.add_child(b)
	game_running = false
	on_mainMenuOpened.emit()
	if adManager && adManager.is_node_ready() && adManager.admob_initialized:
		adManager.setup_interstitial_ad()


func mainMenu():
	#TODO: Pause button dissapears when going back to the menu from a level, then back into a level
	#not sure there's anything here doing it, just needed to write it somewhere.
	if game_running:
		on_gameOver.emit()
	else:
		if(currentWorld != null):
			currentWorld.queue_free()
			currentWorld = null
		var b = BUBBLE_CUTSCENE.instantiate()
		b.skipEntireCutscene = true
		b.levelSelect = false
		currentWorld = b
		get_tree().root.add_child(b)
		on_mainMenuOpened.emit()
		game_running = false


func startGame():
	assert(!game_running)
	GameSettings.currentScore = 0

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
	
	player_spawners = get_tree().root.find_children("PlayerStart*","Node2D",true,false)
	
	var playerIndex = -1
	for id in GlobalInputMap.ControllerIds:
		playerIndex += 1
		if(id != -1):
			var spawner : PlayerSpawner = player_spawners[playerIndex]
			spawner.playerID = playerIndex
			var spawned_player : PlayerDog = spawner.spawn_player()
			if spawned_player != null:
				players.push_back(spawned_player)

	Logging.logMessage("Starting game!")
	match game_mode:
		GAME_MODE.LAST_DOG_STANDING:
			Logging.logMessage("Last dog Standing!")
			for p in players:
				GlobalInputMap.Player_Lives[p.playerID] = lives
				GlobalInputMap.Player_Placement[p.playerID] = 1
		GAME_MODE.TIME:
			Logging.logMessage("Time: " + str(round_time_seconds))

			## +1 second since _actually_start_game() happens after transition in, 
			## but the visual timer doesn't start until on_gameBegin is emitted, 
			## which is after transition out.
			game_timer.start(round_time_seconds+1)
		GAME_MODE.SCORE:
			Logging.logMessage("Score! Round time: " + str(round_time_seconds))
			
			## +1 second since _actually_start_game() happens after transition in, 
			## but the visual timer doesn't start until on_gameBegin is emitted, 
			## which is after transition out.
			game_timer.start(round_time_seconds+1) 
			for p in players:
				GlobalInputMap.Player_Score[p.playerID] = 0
		GAME_MODE.SINGLE_PLAYER: 
			Logging.logMessage("Single player!")
			var p = players[0]
			GlobalInputMap.Player_Score[p.playerID] = 0
			GlobalInputMap.Player_Lives[p.playerID] = lives
			
			
func game_over():
	if ! game_running: 
		return
	if OS.has_feature("mobile"):	
		increment_achievement("Hungry dog", currentScore)
		increment_achievement("Insatiable dog", currentScore)

	if currentWorld != null:
		currentWorld.queue_free()
		currentWorld = null
	if currentScore > highScores.get_or_add(currentMap.name,0):
		highScores[currentMap.name] = currentScore
		saveScore()
	var ui : GameOverScreen = null
	if game_mode == GAME_MODE.SINGLE_PLAYER:
		ui = GAME_OVER_SCREEN.instantiate()
	else:
		ui = ARENA_GAME_OVER_SCREEN.instantiate()
		
	mainGuiNode.add_child(ui)
	
	Logging.logMessage("Game over!")
	ui.game_over(players)
	players.clear()
	
	for s in player_spawners:
		s.stop_timer()
	player_spawners.clear()
	GlobalInputMap.Player_Lives.clear()
	GlobalInputMap.Player_Score.clear()
	GlobalInputMap.Player_Placement.clear()
	get_tree().create_timer(0.3).timeout.connect(ui.show_buttons)
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
	
func remove_all_ads():
	adManager.remove_banner_ad()
	adManager.queue_free()
	adManager = null
	
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
	
	#var pauseScreen = PAUSE_MENU.instantiate()
	#$"../Main/CanvasLayer/Gui".add_child(pauseScreen)
	UINavigator.open_from_scene(PAUSE_MENU)
	get_tree().paused = true


func _on_viewport_size_changed():
	var viewportSize:Vector2 = get_viewport().size
	Logging.logMessage("Viewport size: " + str(get_viewport().size))
	if viewportSize.x > viewportSize.y:
		viewMode = ViewportMode.LANDSCAPE
	else:
		viewMode = ViewportMode.PORTRAIT
		
		
func player_lost(player : PlayerDog) -> void:
	if !game_running:
		return
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
		GAME_MODE.SINGLE_PLAYER:
			on_gameOver.emit()
			
	
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
	if highScores[leaderboard.display_name] >= 20:
		unlock_achievement(leaderboard.display_name)

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
		if highScores[key] >= 20:
			unlock_achievement(key)
			
func _on_billing_manager_loading_finished() -> void:
	if adManager:
		adManager.initialize() 

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


func _get_achievement(achievementName:String) -> PlayGamesAchievement:
		var achievementNum = achievementsCache.find_custom(func(a:PlayGamesAchievement): return a.achievement_name.contains(achievementName))
		return achievementsCache[achievementNum]
#Should probably do something like save achievement unlocks and progress locally, 
#so we can instantly unlock things if players authenticate after playing for a while?
func unlock_achievement(achievementName:String):
	if userAuthenticated and achievementsClient and achievementsCache.size()>0:
		var ach: PlayGamesAchievement = _get_achievement(achievementName)
		if ach.state != PlayGamesAchievement.State.STATE_UNLOCKED: 
			Logging.logMessage("Score is high enough for achievement! Unlocking achievement " + ach.achievement_name)
			achievementsClient.unlock_achievement(ach.achievement_id)
		else:
			Logging.logMessage("Score is high enough for achievement, and achievement is already unlocked! " + ach.achievement_name)

func increment_achievement(achievementName:String, amount:int):
	if userAuthenticated and achievementsClient and achievementsCache.size()>0:
		var ach:PlayGamesAchievement = _get_achievement(achievementName)
		if ach.state != PlayGamesAchievement.State.STATE_UNLOCKED:
			Logging.logMessage("Incrementing achievement " + ach.achievement_name)
			achievementsClient.increment_achievement(ach.achievement_id, amount)
