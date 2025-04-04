extends Control

var score : int

@export var bonusScreenThreshold = 30


@onready var BGmusic = get_tree().root.find_child("BGMusic", true, false)
@onready var levelSelect = preload("res://Scenes/LevelSelect.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#GameOver(false)
	
func SetScore():
	print_debug("Setting Scores in game over screen!")
	score = GameSettings.currentScore
	var str_score : String = var_to_str(score)
	$ScoreLabels/ScoreLabel.text = "Score: " + str_score
	
	if score > GameSettings.highScore:
		GameSettings.highScore = score
		GameSettings.saveScore()
	$ScoreLabels/HighScoreLabel.text = "Best: " + var_to_str(GameSettings.highScore)

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
	GameSettings.currentScore = 0
	
func _on_leaderboard_pressed() -> void:	
	GameSettings.ShowLeaderboard()
	pass # Replace with function body.

func _on_user_authenticated(is_authenticated: bool) -> void:
	if is_authenticated:
		$Leaderboard.visible = true
		print_debug("Authenticated!")
	else:
		$Leaderboard.visible = false
		print_debug("Not authenticated!")


func _on_retry_button_pressed() -> void:
	print_debug("Retry Button Pressed!")
	visible = false
	
	var loseMusic = get_tree().root.find_child("LoseMusic", true, false)
	loseMusic.stop()
	BGmusic.play()
	GameSettings.startGame()
	queue_free()


func _on_level_select_button_pressed() -> void:
	var levelSelectScene = levelSelect.instantiate()
	get_parent().add_child(levelSelectScene)
	queue_free()
	pass # Replace with function body.
