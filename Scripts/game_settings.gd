extends Node

signal on_pickup()
signal on_gameOver(won:bool)
signal on_gameBegin()
signal on_pickupSpawned(pickup:Area2D)

@export var currentScore : int = 0 
var currentMap :Map
var highScore : int = 0
var sfxVol = linear_to_db(0.8)
var musicVol = linear_to_db(0.8)
var musicMuted : bool = false
var sfxMuted : bool = false

@onready var gameOverScreen : PackedScene = preload("res://Scenes/GameOverScreen.tscn")
@onready var playerChar : PackedScene = preload("res://Scenes/PlayerDog.tscn")
@onready var leaderboardsClient : PlayGamesLeaderboardsClient = %PlayGamesLeaderboardsClient
@onready var signInClient : PlayGamesSignInClient = %PlayGamesSignInClient
@onready var scoreBoard : PlayGamesLeaderboard
var leaderboardArray : Array[PlayGamesLeaderboard]
var currentWorld : Node2D
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
	
	on_pickup.connect(increaseScore)
	on_gameOver.connect(gameOver)
	#on_gameBegin.connect(startGame)
	call_deferred("doDeferredSetup")	
	
func doDeferredSetup():
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
	
	if not leaderboardsClient:
		printerr("No leaderboards client found!")
	else:
		print_debug("Finding leaderboards!") 
		leaderboardsClient.all_leaderboards_loaded.connect(all_leaderboards_loaded)
		leaderboardsClient.score_submitted.connect(_score_submitted)
		leaderboardsClient.load_all_leaderboards(true)
	if(signInClient):
		signInClient.user_authenticated.connect(_on_user_authenticated)
	
func startGame():
	if(currentWorld != null):
		currentWorld.queue_free()
	else:
		print_debug("No existing world")
	currentWorld = currentMap.Scene.instantiate()
	get_tree().root.add_child(currentWorld)
	on_gameBegin.emit.call_deferred()
	
func gameOver(won:bool):
	var ui = gameOverScreen.instantiate()
	get_tree().root.find_child("Gui", true, false).add_child(ui)
	ui.GameOver(won)
	if leaderboardsClient:
		print_debug("Submitting Score: " + var_to_str(currentScore))
		var submitted : bool = false
		for board in leaderboardArray:
			if board.display_name == currentMap.name:
				scoreBoard = board
				leaderboardsClient.submit_score(scoreBoard.leaderboard_id,currentScore)
				submitted = true
		if !submitted:
			printerr("Score was never submitted!")
		
func increaseScore():
	currentScore+=1
		

func saveScore():
	print_debug("Saving!")
	var saveFile = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	
	var saveDict = {"highScore" = highScore, "musicVol" = db_to_linear(musicVol), "sfxVol" = db_to_linear(sfxVol), "musicMuted" = musicMuted, "sfxMuted" = sfxMuted} 
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
			printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_str, " at line ", json.get_error_line())
			continue
		var node_data : Dictionary = json.data
		
		highScore = node_data["highScore"]
		
		if node_data.has("sfxVol"):
			sfxVol = linear_to_db(node_data["sfxVol"])
		else:
			printerr("Could not load SFX volume from save file!")
			sfxVol = linear_to_db(0.8)
		if node_data.has("musicVol"):
			musicVol = linear_to_db(node_data["musicVol"])
		else:
			printerr("Could not load music volume from save file!")
			musicVol = linear_to_db(0.8)
			
		if node_data.has("sfxMuted"):
			sfxMuted = node_data["sfxMuted"]
			if(sfxMuted):
				setSFXVol(linear_to_db(0))
		else:
			printerr("Could not load SFX muted from save file!")
			sfxMuted = false
	
		if node_data.has("musicMuted"):
			musicMuted = node_data["musicMuted"]
			if(musicMuted):
				setMusicVol(linear_to_db(0))
		else:
			printerr("Could not load music muted from save file!")
			musicMuted = false

			
	print_debug("Finished loading")
		
func setSFXVol(in_vol : float):
	sfxVol = in_vol
	for audio : AudioStreamPlayer2D in get_tree().root.find_children("*", "AudioStreamPlayer2D", true, false):
		audio.volume_db = in_vol


func setMusicVol(in_vol : float):
	musicVol = in_vol
	for audio : AudioStreamPlayer in get_tree().root.find_children("*", "AudioStreamPlayer", true, false):
		audio.volume_db = in_vol

func _on_music_mute_toggled(toggled_on: bool) -> void:
	musicMuted = toggled_on
	var vol : float = linear_to_db(0.8)
	if musicMuted: 
		vol = linear_to_db(0)
	setMusicVol(vol)
	saveScore()


func _on_sfx_mute_toggled(toggled_on: bool) -> void:
	sfxMuted = toggled_on
	var vol : float = linear_to_db(0.8)
	if sfxMuted: 
		vol = linear_to_db(0)
	setSFXVol(vol)
	saveScore()

func ShowLeaderboard():
	if(leaderboardsClient):
		leaderboardsClient.show_leaderboard(scoreBoard.leaderboard_id)

func all_leaderboards_loaded(leaderboards: Array[PlayGamesLeaderboard]) -> void:
	print_debug("All leaderboards loaded!")
	if not leaderboards.size() == 0:
		leaderboardArray = leaderboards
		scoreBoard = leaderboardArray.front()
	else:
		printerr("No leaderboards found!")
	pass # Replace with function body.

func _on_user_authenticated(is_authenticated: bool) -> void:
	if is_authenticated:
		$Leaderboard.visible = true
		print_debug("Authenticated!")
	else:
		$Leaderboard.visible = false
		print_debug("Not authenticated!")

func _score_submitted(is_submitted: bool, leaderboard_id: String) -> void:
	if is_submitted:
		print_debug("Score Submitted!")
		leaderboardsClient.load_player_score(leaderboard_id,PlayGamesLeaderboardVariant.TimeSpan.TIME_SPAN_ALL_TIME, PlayGamesLeaderboardVariant.Collection.COLLECTION_PUBLIC)
	else: 
		printerr("Score not submitted!")
	pass # Replace with function body.
