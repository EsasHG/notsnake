extends Control

class_name  ArenaGameOverScreen

@export var bonusScreenThreshold = 30

@onready var BGmusic = get_tree().root.find_child("BGMusic", true, false)
@onready var button_container: HBoxContainer = $ButtonContainer
@onready var retry_button: Button = $ButtonContainer/RetryButton
@onready var level_select_button: Button = $ButtonContainer/LevelSelectButton
@onready var main_menu_button: Button = $ButtonContainer/MainMenuButton

@onready var visibleButtonYPos : float = button_container.position.y
@onready var hiddenButtonYOffset : float = 150
@onready var winner_label: Label = $VBoxContainer/WinnerLabel
@onready var score_label_winner: Label = $VBoxContainer/ScoreLabelWinner
@onready var place_2: Label = $VBoxContainer/HBoxContainer/Place_2
@onready var place_3: Label = $VBoxContainer/HBoxContainer2/Place_3
@onready var place_4: Label = $VBoxContainer/HBoxContainer3/Place_4
var placements: Dictionary 
var buttons_enabled = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_container.position.y = visibleButtonYPos+hiddenButtonYOffset
	$ButtonContainer/RetryButton.grab_focus()
	$VBoxContainer/HBoxContainer.visible = false
	$VBoxContainer/HBoxContainer2.visible = false
	$VBoxContainer/HBoxContainer3.visible = false
	disable_buttons()
	
func SetScore():
	Logging.logMessage("Setting Scores in game over screen!")
	
	
func GameOver(players:Array[PlayerDog]):
	Logging.logMessage("Game over!")
	match GameSettings.game_mode:
		GameSettings.GAME_MODE.LAST_DOG_STANDING:
			Logging.logMessage("Last dog Standing!")
			if players.size() == 1:
				
				var sorted_keys = GlobalInputMap.Player_Placement.keys()
				sorted_keys.sort_custom(func(a, b):
					return GlobalInputMap.Player_Placement[b] > GlobalInputMap.Player_Placement[a]
					)
				var i = 0
				for p in sorted_keys:
					placements[i] = { "Player": p, "Score": -1 }
					i+=1
					
				
		GameSettings.GAME_MODE.TIME:
			Logging.logMessage("Time!")
			if players.size() > 0:
				players.sort_custom(func(a:PlayerDog,b:PlayerDog):
					return a.score > b.score;
					)
				var i = 0
				for p in players:
					placements[i] = { "Player": p.playerID, "Score": p.score }
					i+=1
				
		GameSettings.GAME_MODE.SCORE:
			if players.size() > 0:
				var sorted_keys = GlobalInputMap.Player_Score.keys()
				
				sorted_keys.sort_custom(func(a, b):
					return GlobalInputMap.Player_Score[a.playerID] > GlobalInputMap.Player_Score[b.playerID]
					)
				var i = 0
				for p in sorted_keys:
					placements[i] = { "Player": p, "Score": GlobalInputMap.Player_Score[p] }
					i+=1
			
				
				
	SetScore()
	
	for p in placements:
		if p == 0:
			set_label_text(winner_label, placements[p]["Player"], placements[p]["Score"])
			
			winner_label.text = "Player " + str(placements[p]["Player"]+1) + " won!"
			if GameSettings.game_mode != GameSettings.GAME_MODE.LAST_DOG_STANDING:
				score_label_winner.text = "Score: " + str(placements[p]["Score"])
				score_label_winner.visible = true
				score_label_winner.add_theme_color_override("font_color", 
					GlobalInputMap.player_colors[GlobalInputMap.Player_Color_Selected[placements[p]["Player"]]])
				
			else:
				score_label_winner.visible = false
		else:
			match p:
				1:
					set_label_text(place_2, placements[p]["Player"], placements[p]["Score"])
				2:
					set_label_text(place_3, placements[p]["Player"], placements[p]["Score"])
				3:
					set_label_text(place_4, placements[p]["Player"], placements[p]["Score"])
		
	
	$WinnerTex.visible = true

func set_label_text(l:Label, player:int, score:int) -> void:
	l.add_theme_color_override("font_color", GlobalInputMap.player_colors[GlobalInputMap.Player_Color_Selected[player]])
	if score > -1:
		l.text = "Player " + str(player+1) + ". Score: " + str(score) 
	else:
		l.text = "Player " + str(player+1)
	
	l.visible = true
	l.get_parent().visible = true
	visible = true
	
func showButtons() -> void:
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
