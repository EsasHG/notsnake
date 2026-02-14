extends Control

class_name  GameOverScreen

@export var bonusScreenThreshold = 30

@onready var BGmusic = get_tree().root.find_child("BGMusic", true, false)
@onready var button_container: VBoxContainer = $ButtonContainer
@onready var retry_button: Button = $ButtonContainer/RetryButton
@onready var main_menu_button: Button = $ButtonContainer/MainMenuButton
@onready var leaderboard_button: AudioButton = $ButtonContainer/Leaderboard
@onready var unlocks_container: VBoxContainer = $UnlocksContainer
@onready var unlock_title_label: Label = $UnlocksContainer/OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/TitleLabel
@onready var unlock_description_label: Label = $UnlocksContainer/OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/DescriptionLabel
@onready var unlock_texture: TextureRect = $UnlocksContainer/OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/TextureRect


@onready var visibleButtonYPos : float = button_container.position.y
@export var hiddenButtonYPos_landscape : float = 747.0
var hiddenButtonYPos_portrait: float = hiddenButtonYPos_landscape + 560
var buttons_enabled = false


func _ready():
	if OS.has_feature("mobile") and GameSettings.userAuthenticated:
		leaderboard_button.visible = true
	else:
		leaderboard_button.visible = false
		retry_button.grab_focus(true)
	
	if GameSettings.viewport_mode == GameSettings.VIEWPORT_MODE.PORTRAIT:
		button_container.position.y = hiddenButtonYPos_landscape
	else:
		button_container.position.y = hiddenButtonYPos_landscape
	unlocks_container.visible = false
	disable_buttons()
	get_viewport().size_changed.connect(_on_viewport_changed)


func _on_viewport_changed() -> void:
	var viewportSize:Vector2 = get_viewport().size
	if viewportSize.x >= viewportSize.y:	
		button_container.position.y = hiddenButtonYPos_landscape
	else:
		button_container.position.y = hiddenButtonYPos_landscape
	

func _set_score(score : int):
	Logging.logMessage("Setting Scores in game over screen!")
	var highScore : int = GameSettings.getCurrentMapHighScore()
	
	$ScoreLabels/ScoreLabel.text = "Score: " + var_to_str(score)
	$ScoreLabels/HighScoreLabel.text = "Best: " + var_to_str(highScore)
	

func game_over(players:Array[PlayerDog]):
	
	if OS.has_feature("mobile") and GameSettings.userAuthenticated:
		leaderboard_button.visible = true
	else:
		leaderboard_button.visible = false
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
	
	
func check_unlocks() -> void:
	if GameSettings._new_unlocks.size() > 0:
		var unlock: String = GameSettings._new_unlocks.pop_front()
		var type: String 
		var icon: Texture2D = null
		## TODO: if more types are added, fix this
		if GlobalInputMap.Maps.has(unlock):
			type = "LEVEL"
			if unlock == "WINTER":
				icon = GlobalInputMap.Maps[unlock].res.icon
			icon = GlobalInputMap.Maps[unlock].icon
		else:
			type = "HAT" 
			icon = GlobalInputMap.Player_Hats[unlock].icon_hat
		if icon:
			unlock_texture.texture = icon
			unlock_texture.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		unlock_title_label.text = tr(type + "_UNLOCKED_TITLE")
		unlock_description_label.text = tr(unlock) + " " + tr(type + "_UNLOCKED_DESCRIPTION") 
		UINavigator.open(unlocks_container, false, false, check_unlocks)
	else:
		show_buttons()


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
