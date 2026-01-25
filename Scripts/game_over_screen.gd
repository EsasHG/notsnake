extends Control

class_name  GameOverScreen

@export var bonusScreenThreshold = 30

@onready var BGmusic = get_tree().root.find_child("BGMusic", true, false)
@onready var button_container: HBoxContainer = $ButtonContainer
@onready var retry_button: Button = $ButtonContainer/RetryButton
@onready var level_select_button: Button = $ButtonContainer/LevelSelectButton
@onready var main_menu_button: Button = $ButtonContainer/MainMenuButton

@onready var visibleButtonYPos : float = button_container.position.y
@onready var hiddenButtonYOffset : float = 150
var buttons_enabled = false

func _ready():
	if OS.has_feature("mobile") and GameSettings.userAuthenticated:
		$ButtonContainer/Leaderboard.visible = true
	else:
		$ButtonContainer/Leaderboard.visible = false
		$ButtonContainer/RetryButton.grab_focus()

	button_container.position.y = visibleButtonYPos+hiddenButtonYOffset
	disable_buttons()
	
func _set_score(score : int):
	Logging.logMessage("Setting Scores in game over screen!")
	var highScore : int = GameSettings.getCurrentMapHighScore()
	
	$ScoreLabels/ScoreLabel.text = "Score: " + var_to_str(score)
	$ScoreLabels/HighScoreLabel.text = "Best: " + var_to_str(highScore)
	
func game_over(players:Array[PlayerDog]):
	
	if OS.has_feature("mobile") and GameSettings.userAuthenticated:
		$ButtonContainer/Leaderboard.visible = true
	else:
		$ButtonContainer/Leaderboard.visible = false
	Logging.logMessage("Game over!")
	
	var player : PlayerDog = players[0]
	_set_score(player.score)
	
	#stuff that should happen if player grabs own tail.
	if player.grabbed_tail:
		Logging.logMessage("Player Won!")
		$LongDogTex.visible = false
		$WinnerTex.visible = true
		$GameOverTex.visible = false
	elif(player.score > bonusScreenThreshold):
		Logging.logMessage("Player got over 20 treats!")
		$LongDogTex.visible = true
		$WinnerTex.visible = false
		$GameOverTex.visible = false
	else:
		$LongDogTex.visible = false
		$WinnerTex.visible = false
		$GameOverTex.visible = true
	
	
func show_buttons() -> void:
	Logging.logMessage("Showing buttons in game over!")
	disable_buttons()
	var tween : Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button_container,"position:y",visibleButtonYPos,0.2)
	tween.finished.connect(enable_buttons)
	
func enable_buttons() -> void:
	buttons_enabled = true

func disable_buttons() -> void:
	buttons_enabled = false
	
	
func _on_retry_button_pressed() -> void:
	if !buttons_enabled:
		return
	disable_buttons()
	
	var loseMusic = get_tree().root.find_child("LoseMusic", true, false)
	loseMusic.stop()
	BGmusic.play()
	GameSettings.startGame()
	GameSettings.on_gameBegin.connect(queue_free)
	#queue_free()

func _on_level_select_button_pressed() -> void:
	if !buttons_enabled:
		return
		
	disable_buttons()
	
	var loseMusic = get_tree().root.find_child("LoseMusic", true, false)
	loseMusic.stop()
	GameSettings.levelSelect()
	queue_free()
	pass # Replace with function body.


func _on_main_menu_button_pressed() -> void:
	if !buttons_enabled:
		return
	disable_buttons()
	
	var loseMusic = get_tree().root.find_child("LoseMusic", true, false)
	loseMusic.stop()
	GameSettings.mainMenu()
	queue_free()

func _on_leaderboard_pressed() -> void:	
	GameSettings.showLeaderboard()
	pass # Replace with function body.
