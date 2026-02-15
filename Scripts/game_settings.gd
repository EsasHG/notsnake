extends Node

signal on_pickup()
signal on_gameOver()
signal on_gameBegin()
signal on_gamePaused()
signal on_gameUnpaused()
signal on_pickupSpawned(pickup:Area2D)
signal on_mainMenuOpened()
signal on_controls_changed(holdControls:bool)
signal on_dogColorChanged(color:Color)
signal on_dogHatChanged(hat:String)
signal on_somethingUnlocked(unlock:String)
const BILLING_MANAGER = preload("uid://di83hh7jce01j")

var time_scale_tween : Tween

@export var currentScore : int = 0 

enum GAME_MODE {LAST_DOG_STANDING, TIME, SCORE, SINGLE_PLAYER}
#var game_mode :GAME_MODE = GAME_MODE.LAST_DOG_STANDING
var game_mode :GAME_MODE = GAME_MODE.SINGLE_PLAYER

@onready var game_timer : Timer = Timer.new()
var round_time_seconds:int = 60 
var lives = 1
var game_running:bool = false
var language = "automatic"
var banner_ad_showing = false
const SCENE_TRANSITION = preload("uid://gsu5a1hu0rjf")
const GAME_OVER_SCREEN = preload("uid://ck7vl8h740cpk")
const ARENA_GAME_OVER_SCREEN = preload("uid://u1gfn45v12yd")

#const PAUSE_OVERLAY = preload("uid://ba4bi555qsw1v")

const PAUSE_MENU = preload("uid://d0eb6heqgmexf")
const BUBBLE_CUTSCENE = preload("uid://3va5fhmx5hn4")

@onready var signInClient : PlayGamesSignInClient = get_tree().root.find_child("PlayGamesSignInClient", true, false)
@onready var mainGuiNode = get_tree().root.find_child("Gui", true, false)
var adManager : AdManager = null
var billingManager : BillingManager = null

var player_spawners : Array[Node]

var players : Array[PlayerDog]
enum VIEWPORT_MODE {PORTRAIT, LANDSCAPE}
var viewport_mode:VIEWPORT_MODE = VIEWPORT_MODE.LANDSCAPE

var currentMap :Map
var highScores = {"Field":0, "Park": 0, "Square": 0, "Small":0, "Forest":0, "Winter":0}
var sfxVol = linear_to_db(0.8)
var musicVol = linear_to_db(0.8)
var musicMuted : bool = false
var sfxMuted : bool = false
var userAuthenticated = false

var achievementsClient : PlayGamesAchievementsClient = null
var leaderboardsClient : PlayGamesLeaderboardsClient = null
var scoreBoard : PlayGamesLeaderboard
var leaderboardArray : Array[PlayGamesLeaderboard]
var achievementsCache: Array[PlayGamesAchievement]
var times_crashed : int = 0

## So we can notify the player when convenient
var _new_unlocks: Array[String]

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
	SaveManager.load_score()	
	
	if not SaveManager.load_settings():
		sfxMuted = false
		musicMuted = false
		setSFXMuted(sfxMuted)
		setMusicMuted(musicMuted)
	
	SaveManager.load_unlocks()
	
	on_pickup.connect(increaseScore)
	on_gameOver.connect(game_over)
	on_gameBegin.connect(func(): 
		game_running = true	
		)
	on_somethingUnlocked.connect(_on_something_unlocked)
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()
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
		
		
		if mainGuiNode:
			billingManager = BILLING_MANAGER.instantiate()
			billingManager.loading_finished.connect(_on_billing_manager_loading_finished)
			mainGuiNode.call_deferred("add_child", billingManager)
		else: 
			print("Main gui node not found! Not adding billing manager...")
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
		
	var scene_transition:SceneTransition = get_tree().root.find_child("SceneTransition",true,false)
	get_tree().create_timer(1.5).timeout.connect(func(): if scene_transition: scene_transition.transition_out())

func end_run() -> void:
	if !game_running:
		Logging.error("End run called, but game is not running!")
	else:
		on_gameOver.emit()
	

func mainMenu():
	#TODO: Pause button dissapears when going back to the menu from a level, then back into a level
	#not sure there's anything here doing it, just needed to write it somewhere.
	if game_running:
		Logging.error("main_menu called, but game is running! Stopping game...")
		on_gameOver.emit()
	else:
		var transition: SceneTransition = _create_transition()
		
		transition.transition_in_finished.connect(func():
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
				get_tree().create_timer(1).timeout.connect(func(): 
						transition.transition_out()
						)
				)
		
		


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
		
	var save_unlocks : bool = false
	if currentWorld != null:
		currentWorld.queue_free()
		currentWorld = null
		
	if currentScore > highScores.get_or_add(currentMap.name,0):
		highScores[currentMap.name] = currentScore
		SaveManager.save_score()
	## This should work, but only if the maps in GlobalInputMap are in the right order, 
	## and unlock condition is always 20 points on the previous map...
	if currentScore >= 20:
		var unlock_map: bool = false
		for map in GlobalInputMap.Maps:
			if unlock_map:
				on_somethingUnlocked.emit(map)
				GlobalInputMap.Maps[map].unlocked = true
				save_unlocks = true
				break
			if map == currentMap.name:
				unlock_map = true
	
	if times_crashed > 100 and not GlobalInputMap.Player_Hats["HELMET"].unlocked:
		GlobalInputMap.Player_Hats["HELMET"].unlocked = true
		on_somethingUnlocked.emit("HELMET")
	
	if save_unlocks:
		SaveManager.save_unlocks()
	
	SaveManager.save_settings() ## Doing this so times_crashed gets saved.
	
	var game_over_screen : GameOverScreen = null
	if game_mode == GAME_MODE.SINGLE_PLAYER:
		game_over_screen = GAME_OVER_SCREEN.instantiate()
	else:
		game_over_screen = ARENA_GAME_OVER_SCREEN.instantiate()
		
	mainGuiNode.add_child(game_over_screen)
	
	Logging.logMessage("Game over!")
	game_over_screen.game_over(players)
	players.clear()
	
	for s in player_spawners:
		s.stop_timer()
	player_spawners.clear()
	GlobalInputMap.Player_Lives.clear()
	GlobalInputMap.Player_Score.clear()
	GlobalInputMap.Player_Placement.clear()
	
	game_running = false
	
	if OS.has_feature("mobile") && game_mode == GAME_MODE.SINGLE_PLAYER:
		if userAuthenticated:
			increment_achievement("Hungry dog", currentScore)
			increment_achievement("Insatiable dog", currentScore)
			
			if leaderboardsClient:
				Logging.logMessage("Trying to submit score: " + var_to_str(currentScore))
				var submitted : bool = false
				for board in leaderboardArray:
					if board.leaderboard_id == PlayGamesIDs.leaderboards[currentMap.name]:
						scoreBoard = board
						Logging.logMessage("Leaderboard found. Submitting Score: " + var_to_str(currentScore))
						leaderboardsClient.submit_score(scoreBoard.leaderboard_id,currentScore)
						submitted = true
				if !submitted:
					Logging.error("Could not find a leaderboard with name "+ currentMap.name + "! Score was never submitted!")
		if adManager:
			adManager.rounds_played+=1
			if adManager.admob_initialized and adManager._can_show_interstitial_ad and adManager.interstitial_ad_loaded:
				get_tree().create_timer(0.6).timeout.connect(func(): 
					adManager.show_interstitial_ad()
					)
				get_tree().create_timer(0.75).timeout.connect(game_over_screen.check_unlocks) # i migth want different wait times in the future
			else: 
				get_tree().create_timer(0.3).timeout.connect(game_over_screen.check_unlocks)
		else: 
			get_tree().create_timer(0.3).timeout.connect(game_over_screen.check_unlocks)
	else:
		get_tree().create_timer(0.3).timeout.connect(game_over_screen.check_unlocks)
		
	currentScore = 0


func increaseScore():
	currentScore+=1

		
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


func setSFXMuted(muted:bool):
	Logging.logMessage("Setting sfx muted to " + str(muted))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"),muted)
	sfxMuted = muted
	var vol : float = linear_to_db(0.8)
	if sfxMuted: 
		vol = linear_to_db(0)
	setSFXVol(vol)


func setControls(hold:bool):
	GlobalInputMap.Player_Controls_Selected[0] = hold
	on_controls_changed.emit(hold)
	

func remove_all_ads():
	adManager.remove_banner_ad()
	adManager.queue_free()
	adManager = null
	
func _on_something_unlocked(unlock:String):
	_new_unlocks.append(unlock)
	

func _create_transition() -> SceneTransition:
	var transition : SceneTransition = SCENE_TRANSITION.instantiate()
	mainGuiNode.add_child.call_deferred(transition)
	return transition


func _on_music_mute_toggled(toggled_on: bool) -> void:
	setMusicMuted(toggled_on)


func _on_sfx_mute_toggled(toggled_on: bool) -> void:
	setSFXMuted(toggled_on)


func pause_game():
	Logging.logMessage("Pausing game")
	#var pauseScreen = PAUSE_MENU.instantiate()
	#$"../Main/CanvasLayer/Gui".add_child(pauseScreen)
	UINavigator.open_from_scene(PAUSE_MENU,true, false, unpause_game)
	get_tree().paused = true
	on_gamePaused.emit()


func unpause_game() -> void:
	if time_scale_tween and time_scale_tween.is_valid():
		time_scale_tween.kill()
	
	get_tree().paused = false
	Engine.time_scale = 0
	time_scale_tween = get_tree().create_tween()
	time_scale_tween.set_ignore_time_scale(true)
	time_scale_tween.set_ease(Tween.EASE_IN)
	time_scale_tween.tween_property(Engine, "time_scale", 1, 2)
	on_gameUnpaused.emit()
	

func _on_viewport_size_changed():
	var viewportSize:Vector2 = get_viewport().size
	Logging.logMessage("Viewport size: " + str(get_viewport().size))
	if viewportSize.x >= viewportSize.y:
		viewport_mode = VIEWPORT_MODE.LANDSCAPE
	else:
		viewport_mode = VIEWPORT_MODE.PORTRAIT
		
		
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
			times_crashed += 1
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
