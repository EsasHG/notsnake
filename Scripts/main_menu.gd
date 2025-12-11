extends Control

@export var playerSlots: Array[PlayerSlot]

var startButtonPressed = false
var quitButtonPressed = false
var startButtonStayFilled = false
var justPressed = false
var justPressedTime = 0.2
var start_focused = preload("res://Assets/UI/startbutton_5.png")
var quit_unfocused = preload("res://Assets/UI/QUIT_3.png")
var menu_active = true;
const ARENA = preload("uid://sctscfmi6mda")

@onready var settings_container: PanelContainer = $SettingsContainer
#@onready var level_select_container: VBoxContainer = $LevelSelectContainer
@onready var buttons: HBoxContainer = $HBoxContainer
@onready var level_select_screen: Control = $LevelSelectScreen
@onready var level_buttons: HFlowContainer = $LevelSelectScreen/VBoxContainer/PanelContainer/LevelButtons
@onready var level_selected_sound: AudioStreamPlayer = get_tree().root.find_child("LevelSelected", true, false)
@onready var h_box_container_2: HBoxContainer = $HBoxContainer2
@onready var game_settings_container: Panel = $GameSettingsContainer
@onready var level_select_back: Button = $LevelSelectScreen/VBoxContainer/ButtonContainer/Back

@export var buttonTheme:Theme
@export var levels : Array[Map]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	hide_all()
	buttons.visible = true
	#$Panel2.visible = true
	get_tree().create_timer(0.5).timeout.connect(func():	
		var blackPanelTween = get_tree().create_tween()
		blackPanelTween.set_ease(Tween.EASE_IN)
		blackPanelTween.tween_property($Panel2, "modulate:a", 0, 1.5)
		)
	
	if(!OS.has_feature("web") && !OS.has_feature("mobile")):
		$HBoxContainer/StartButton.grab_focus()
	
	var music = get_tree().root.find_child("BGMusic", true, false)
	if(music):
		music.play()
	
	for s : Map in levels:
		var button : Button = Button.new()
		button.theme = buttonTheme
		button.icon = s.icon
		button.text = s.name
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.expand_icon = true
		button.custom_minimum_size = Vector2(100,100)
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.focus_neighbor_bottom = level_select_back.get_path()
		level_buttons.add_child(button)
		button.pressed.connect(_on_map_selected.bind(s))
	

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("MenuCancel") and event.device not in GlobalInputMap.ControllerIds:
		if level_select_screen.visible:
			_on_back_pressed()
		elif game_settings_container.visible:
			_on_game_settings_back_pressed()	
		elif ! menu_active:
			reopen_menu_screen()
	
	if menu_active:
		return
	if event.device not in GlobalInputMap.ControllerIds && event.is_action_released("MenuSelect"):
		var index = 0;
		while GlobalInputMap.ControllerIds[index] != -1 && index < 4:
			index += 1;
		if index != 4:
			playerSlots[index].setID(event.device)
	if event.is_action_pressed("MenuStart") and event.device in GlobalInputMap.ControllerIds and playerSlots.all(func(it): return it.ready_to_play()):
		start_game()
		



func start_game() -> void:
	GameSettings.startGame()
	queue_free()
	
func filled():
	startButtonStayFilled = true
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($HBoxContainer/StartButton, "position", Vector2($HBoxContainer/StartButton.position.x,1126), 0.5)
	tween.tween_callback(menuOut)
	
	var signInTween = get_tree().create_tween()
	signInTween.set_ease(Tween.EASE_IN)
	signInTween.tween_property($"HBoxContainer/Sign In", "position", Vector2($"HBoxContainer/Sign In".position.x,1126), 0.5)
	
	var leaderboardTween = get_tree().create_tween()
	leaderboardTween.set_ease(Tween.EASE_IN)
	leaderboardTween.tween_property($HBoxContainer/Leaderboard,"position", Vector2($HBoxContainer/Leaderboard.position.x,1126), 0.5)
	
	var tween2 = get_tree().create_tween()
	tween2.set_ease(Tween.EASE_IN)
	tween2.tween_property($Logo, "position",Vector2(1056, -500), 0.5)
	
	
func quitFilled():
	get_tree().quit()
	pass
			 
func menuOut():
	$Logo.visible = false
	$HBoxContainer/StartButton.visible = false
	$HBoxContainer/QuitButton.visible = false

	
	
func _on_quit_button_button_down() -> void:
	quitButtonPressed = true
	justPressed = true
	get_tree().create_timer(justPressedTime).timeout.connect(func(): justPressed = false)


func _on_quit_button_button_up() -> void:
	if(justPressed):
		$HBoxContainer/StartButton.grab_focus()
		$HBoxContainer/StartButton/TextureProgressBar.texture_under = start_focused
		
		justPressed = false
	quitButtonPressed = false
	pass # Replace with function body.


func _on_user_authenticated(is_authenticated: bool) -> void:
	Logging.logMessage("Main menu: On user authenticated: " + str(is_authenticated))
	
	$"HBoxContainer/Sign In".visible = !is_authenticated
	#$HBoxContainer/Leaderboard.visible = true


func _on_start_button_pressed() -> void:
	open_game_settings()

func open_game_settings() -> void:
	hide_all()
	game_settings_container.visible = true


func openLevelSelect():
	level_buttons.get_children()[0].grab_focus()
	hide_all()
	level_select_screen.visible = true

func _on_settings_pressed() -> void:
	hide_all()
	settings_container.visible = true

func _on_back_pressed() -> void:
	hide_all()
	game_settings_container.visible = true

func _on_map_selected(scene:Map): 
	level_selected_sound.play()
	GameSettings.currentMap = scene
	menu_deactivated()

func _on_quit_pressed() -> void:
	get_tree().quit();
	pass # Replace with function body.

func reopen_menu_screen():
	menu_active = true
	#buttons.visible = true
	hide_all()
	level_select_screen.visible = true
	level_buttons.get_children()[0].grab_focus()
#	$HBoxContainer/StartButton.grab_focus()
	
func menu_deactivated() -> void:
	hide_all()
	menu_active = false
	h_box_container_2.visible = true


func hide_all() -> void:
	buttons.visible = false
	level_select_screen.visible = false
	h_box_container_2.visible = false
	game_settings_container.visible = false
	settings_container.visible = false
	


func _on_game_settings_start_button_pressed() -> void:
	openLevelSelect()


func _on_game_settings_back_pressed() -> void:
	hide_all()
	buttons.visible = true
	$HBoxContainer/StartButton.grab_focus()
	
