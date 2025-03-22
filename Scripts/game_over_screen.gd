extends Control

var retryButtonPressed = false
var quitButtonPressed = false
var justPressed = false
var justPressedTime = 0.2
var retry_unfocused = preload("res://Assets/UI/RETRY_2.png")
var retry_focused = preload("res://Assets/UI/RETRY_5.png")

var quit_unfocused = preload("res://Assets/UI/QUIT_3.png")
var quit_focused = preload("res://Assets/UI/QUIT_1.png")
var score : int

@export var bonusScreenThreshold = 30
@onready var scene = load("res://Scenes/PlayerDog.tscn")
@onready var scoreBoard : PlayGamesLeaderboard
var leaderboardArray : Array[PlayGamesLeaderboard]
@onready var leaderboardsClient : PlayGamesLeaderboardsClient = %PlayGamesLeaderboardsClient

@onready var BGmusic = get_tree().root.find_child("BGMusic", true, false)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not leaderboardsClient:
		printerr("No leaderboards client found!")
	else:
		print_debug("Finding leaderboards!") 
		leaderboardsClient.load_all_leaderboards(true)
		leaderboardsClient.all_leaderboards_loaded.connect(all_leaderboards_loaded)
	visibility_changed.connect(on_visibility_changed)
	if(!OS.has_feature("web") && !OS.has_feature("mobile")):
		if(visible):
			$RetryButton.grab_focus()
	SignalManager.on_gameOver.connect(GameOver)


func on_visibility_changed():
	
	if(!OS.has_feature("web") && !OS.has_feature("mobile")):
		if(visible):
			$RetryButton.grab_focus()
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(!OS.has_feature("web") && !OS.has_feature("mobile")):
		if(quitButtonPressed):
			$QuitButton/TextureProgressBar.value += 80*delta
		elif(!quitButtonPressed):
			$QuitButton/TextureProgressBar.value -= 100*delta
			
		if($QuitButton/TextureProgressBar.value == $QuitButton/TextureProgressBar.max_value):
			quitFilled()
	
		if(retryButtonPressed):
			$RetryButton/TextureProgressBar.value += 80*delta
		else:
			$RetryButton/TextureProgressBar.value -= 100*delta
			
		if($RetryButton/TextureProgressBar.value == $RetryButton/TextureProgressBar.max_value):
			filled()
		
		
func filled():    
	var s : PlayerDog = scene.instantiate()
	get_tree().root.find_child("World", true, false).add_child(s)
	s.grabCamera()
	retryButtonPressed = false 
	visible = false
	$RetryButton/TextureProgressBar.value = 0
	SignalManager.on_gameBegin.emit()
	
	var loseMusic = get_tree().root.find_child("LoseMusic", true, false)
	loseMusic.stop()
	BGmusic.play()
	
func quitFilled():
	get_tree().quit()
	
	
func SetScore():
	score = GameSettings.currentScore
	var str_score : String = var_to_str(score)
	$ScoreLabels/ScoreLabel.text = "Score: " + str_score
	
	if score > GameSettings.highScore:
		GameSettings.highScore = score
		GameSettings.saveScore()
		
	$ScoreLabels/HighScoreLabel.text = "Best: " + var_to_str(GameSettings.highScore)
	
func _on_retry_button_button_down() -> void:
	if(!OS.has_feature("web") && !OS.has_feature("mobile")):
		justPressed = true
		get_tree().create_timer(justPressedTime).timeout.connect(func(): justPressed = false)
	elif OS.has_feature("mobile"):
		filled()
	retryButtonPressed = true
	#get_tree().root.find_child("World", true, false).queue_free()
	#var s = scene.instantiate()
	#get_tree().root.add_child(s)
	#visible = false
	
	pass # Replace with function body.


func _on_retry_button_button_up() -> void:
	
	if(!OS.has_feature("web") && !OS.has_feature("mobile")):
		if(justPressed):
			$QuitButton.grab_focus()
			justPressed = false
		
			$RetryButton/TextureProgressBar.texture_under = retry_unfocused
			$QuitButton/TextureProgressBar.texture_under = quit_focused
	retryButtonPressed = false


func _on_quit_button_button_down() -> void:
	quitButtonPressed = true
	justPressed = true
	get_tree().create_timer(justPressedTime).timeout.connect(func(): justPressed = false)


func _on_quit_button_button_up() -> void:	
	if(justPressed):
		$RetryButton.grab_focus()
		$RetryButton/TextureProgressBar.texture_under = retry_focused
		$QuitButton/TextureProgressBar.texture_under = quit_unfocused
		justPressed = false
	quitButtonPressed = false
	pass # Replace with function body.

func GameOver(won:bool):
	print_debug("Game over!")
	SetScore()
	if(won):
		print_debug("Player Won!")
		$LongDogPanel.visible = false
		$WinnerPanel.visible = true
		$Panel.visible = false
	elif(GameSettings.currentScore > bonusScreenThreshold):
		print_debug("Player got over 20 treats!")
		$LongDogPanel.visible = true
		$WinnerPanel.visible = false
		$Panel.visible = false
	else:
		$LongDogPanel.visible = false
		$WinnerPanel.visible = false
		$Panel.visible = true
		
	visible = true
	if leaderboardsClient && scoreBoard:
		print_debug("Submitting Score: " + var_to_str(GameSettings.currentScore))
		leaderboardsClient.submit_score(scoreBoard.leaderboard_id,GameSettings.currentScore)
		
	GameSettings.currentScore = 0
	

func all_leaderboards_loaded(leaderboards: Array[PlayGamesLeaderboard]) -> void:
	print_debug("All leaderboards loaded!")
	if not leaderboards.size() == 0:
		leaderboardArray = leaderboards
		scoreBoard = leaderboardArray.front()
	else:
		printerr("No leaderboards found!")
	pass # Replace with function body.


func _score_submitted(is_submitted: bool, leaderboard_id: String) -> void:
	if is_submitted:
		print_debug("Score Submitted!")
		leaderboardsClient.load_player_score(leaderboard_id,PlayGamesLeaderboardVariant.TimeSpan.TIME_SPAN_ALL_TIME, PlayGamesLeaderboardVariant.Collection.COLLECTION_PUBLIC)
	else: 
		printerr("Score not submitted!")
	pass # Replace with function body.


func _on_leaderboard_pressed() -> void:	
	leaderboardsClient.show_leaderboard(scoreBoard.leaderboard_id)
	pass # Replace with function body.
