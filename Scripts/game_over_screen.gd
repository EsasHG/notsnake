extends Control

class_name  GameOverScreen

@export var bonusScreenThreshold = 30

@onready var BGmusic = get_tree().root.find_child("BGMusic", true, false)
@onready var button_container: HBoxContainer = $ButtonContainer

@onready var visibleButtonYPos : float = button_container.position.y
@onready var hiddenButtonYOffset : float = 150
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameSettings.userAuthenticated:
		$ButtonContainer/Leaderboard.visible = true
	else:
		$ButtonContainer/Leaderboard.visible = false
		
	button_container.position.y = visibleButtonYPos+hiddenButtonYOffset
	
func SetScore():
	Logging.logMessage("Setting Scores in game over screen!")
	var score : int = GameSettings.currentScore
	var highScore : int = GameSettings.getCurrentMapHighScore()
	
	$ScoreLabels/ScoreLabel.text = "Score: " + var_to_str(score)
	$ScoreLabels/HighScoreLabel.text = "Best: " + var_to_str(highScore)

func GameOver(won:bool):
	
	if GameSettings.userAuthenticated:
		$ButtonContainer/Leaderboard.visible = true
	else:
		$ButtonContainer/Leaderboard.visible = false
	Logging.logMessage("Game over!")
	SetScore()
	if(won):
		
		Logging.logMessage("Player Won!")
		$LongDogTex.visible = false
		$WinnerTex.visible = true
		$GameOverTex.visible = false
	elif(GameSettings.currentScore > bonusScreenThreshold):
		Logging.logMessage("Player got over 20 treats!")
		$LongDogTex.visible = true
		$WinnerTex.visible = false
		$GameOverTex.visible = false
	else:
		$LongDogTex.visible = false
		$WinnerTex.visible = false
		$GameOverTex.visible = true
		
	visible = true
	
func showButtons() -> void:
	Logging.logMessage("Showing buttons in game over!")
	var tween : Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button_container,"position:y",visibleButtonYPos,0.2)
	
func _on_leaderboard_pressed() -> void:	
	GameSettings.showLeaderboard()
	pass # Replace with function body.


func _on_retry_button_pressed() -> void:
	Logging.logMessage("Retry Button Pressed!")
	
	
	var loseMusic = get_tree().root.find_child("LoseMusic", true, false)
	loseMusic.stop()
	BGmusic.play()
	GameSettings.startGame()
	GameSettings.on_gameBegin.connect(queue_free)
	#queue_free()


func _on_level_select_button_pressed() -> void:
	var loseMusic = get_tree().root.find_child("LoseMusic", true, false)
	loseMusic.stop()
	GameSettings.levelSelect()
	queue_free()
	pass # Replace with function body.


func _on_main_menu_button_pressed() -> void:
	var loseMusic = get_tree().root.find_child("LoseMusic", true, false)
	loseMusic.stop()
	GameSettings.mainMenu()
	queue_free()
