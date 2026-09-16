extends Control

class_name  GameOverScreen

@export var bonusScreenThreshold = 30
@export var score_label:Label
@export var high_score_label:Label
@export var leaderboard_button: AudioButton

@export var end_textures : Array[TextureRect]

@onready var BGmusic = get_tree().root.find_child("BGMusic", true, false)
@onready var button_container: VBoxContainer = $ButtonContainer
@onready var retry_button: Button = $ButtonContainer/RetryButton
@onready var main_menu_button: Button = $ButtonContainer/MainMenuButton
@onready var unlocks_container: VBoxContainer = $UnlocksContainer
@onready var unlock_title_label: Label = $UnlocksContainer/OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/TitleLabel
@onready var unlock_description_label: Label = $UnlocksContainer/OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/DescriptionLabel
@onready var unlock_texture: TextureRect = $UnlocksContainer/OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/TextureRect
var buttons_enabled = false


func _ready():
	if OS.has_feature("mobile") and GameSettings.userAuthenticated:
		leaderboard_button.visible = true
	else:
		leaderboard_button.visible = false
		retry_button.grab_focus(true)
		
	#button_container.position.y += hiddenButtonYPos_offset
	#if GameSettings.viewport_mode == GameSettings.VIEWPORT_MODE.PORTRAIT:
		#button_container.position.y = hiddenButtonYPos_landscape
	#else:
		#button_container.position.y = hiddenButtonYPos_landscape
	unlocks_container.visible = false
	button_container.visible = false
	disable_buttons()
	GameSettings.on_viewportChanged.connect(_on_viewport_changed)
	_on_viewport_changed()



func _on_viewport_changed() -> void:
	if GameSettings.viewport_mode == GameSettings.VIEWPORT_MODE.PORTRAIT:
		#game_over_tex.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		for tex in end_textures:
			tex.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP,Control.PRESET_MODE_KEEP_SIZE)
			tex.position.y += 100
		button_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM,Control.PRESET_MODE_KEEP_SIZE)
		button_container.position.y -= 400
		#buttons.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	else:
		#game_over_tex.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
		for tex in end_textures:
			tex.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT,Control.PRESET_MODE_KEEP_SIZE)
		#game_over_tex.position.y += 50
		button_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT,Control.PRESET_MODE_KEEP_SIZE)
		#buttons.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
		button_container.position.x -= 100
	

func _set_score(score : int):
	Logging.logMessage("Setting Scores in game over screen!")
	var highScore : int = GameSettings.getCurrentMapHighScore()
	
	score_label.text = tr("SCORE") + " " + var_to_str(score)
	high_score_label.text =  tr("BEST_SCORE") + " " + var_to_str(highScore)
	

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
	button_container.scale = Vector2(0.3,0.3)
	button_container.visible = true
	var tween : Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button_container,"scale",Vector2(1,1),0.35).set_trans(Tween.TRANS_BACK)
	#tween.tween_property(button_container,"position:y",visibleButtonYPos,0.2)
	tween.finished.connect(enable_buttons)
	
	
func check_show_ad() -> void:
	var adManager = GameSettings.adManager
	if adManager:
		adManager.rounds_played+=1
		if adManager.admob_initialized and adManager._can_show_interstitial_ad and adManager.interstitial_ad_loaded:
			adManager.admob.interstitial_ad_dismissed_full_screen_content.connect(on_ad_dismissed)
			get_tree().create_timer(0.6).timeout.connect(func(): 
				adManager.show_interstitial_ad()
				)					
		else: 
			get_tree().create_timer(0.3).timeout.connect(check_unlocks)
	else: 
		get_tree().create_timer(0.3).timeout.connect(check_unlocks)


func check_unlocks() -> void:
	Logging.logMessage("Checking unlocks..")
	if GameSettings._new_unlocks.size() > 0:
		var unlock: String = GameSettings._new_unlocks.pop_front()
		var type: String 
		var icon: Texture2D = null
		## TODO: if more types are added, fix this
		if GlobalInputMap.Maps.has(unlock):
			type = "LEVEL"
			if unlock == "WINTER":
				icon = GlobalInputMap.Maps[unlock].icon
			icon = GlobalInputMap.Maps[unlock].icon
		else:
			type = "HAT" 
			icon = GlobalInputMap.hats[unlock].texture
		if icon:
			unlock_texture.texture = icon
			unlock_texture.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		unlock_title_label.text = tr(type + "_UNLOCKED_TITLE")
		unlock_description_label.text = ""
		#unlock_description_label.text = tr(unlock) + " " + tr(type + "_UNLOCKED_DESCRIPTION") 
		Logging.logMessage("Showing unlocked item!")
		UINavigator.open(unlocks_container, false, false, check_unlocks)
	else:
		Logging.logMessage("Nothing new unlocked")
		show_buttons()


func on_ad_dismissed(_ad_info):
	#if GameSettings.adManager && GameSettings.adManager.interstitial_ads_shown == 3 && GameSettings.billingManager:
		#GameSettings.billingManager.show_ad_removal_popup()
		#GameSettings.billingManager.popup_dismissed.connect(func(): 
			#get_tree().create_timer(0.3).timeout.connect(check_unlocks)
			#)
	#else:
		#get_tree().create_timer(0.3).timeout.connect(check_unlocks)
	Logging.logMessage("Game_over_screen on_ad_dismissed")
	get_tree().create_timer(0.3).timeout.connect(check_unlocks)



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
	GameSettings.on_gameBegin.connect(queue_free)
	GameSettings.startGame()


func _on_main_menu_button_pressed() -> void:
	if !buttons_enabled:
		return
	disable_buttons()
	
	var loseMusic = get_tree().root.find_child("LoseMusic", true, false)
	loseMusic.stop()
	GameSettings.mainMenu()
	BGmusic.play()
	queue_free()


func _on_leaderboard_pressed() -> void:	
	LeaderboardManager.show_leaderboard()
	pass # Replace with function body.
