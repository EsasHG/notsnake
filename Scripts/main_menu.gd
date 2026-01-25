extends Control

class_name MainMenu

var menu_active = true;

@onready var settings_container: PanelContainer = $SettingsContainer
@onready var settings_back: Button = $SettingsContainer/VBoxContainer/Back
@onready var buttons: HBoxContainer = $MainButtons
@onready var level_select_screen: Control = $LevelSelectScreen
@onready var level_buttons: HFlowContainer = $LevelSelectScreen/VBoxContainer/PanelContainer/LevelButtons
@onready var level_selected_sound: AudioStreamPlayer = get_tree().root.find_child("LevelSelected", true, false)
@onready var level_select_back: Button = $LevelSelectScreen/VBoxContainer/ButtonContainer/Back
@onready var start_button: Button = $MainButtons/Start
@onready var quit_button: Button = $MainButtons/Quit
@onready var sign_in_button: Button = $"MainButtons/Sign In"
@onready var settings_button: Button = $MainButtons/Settings

@export var buttonTheme:Theme
@export var levels : Array[Map]


func _ready() -> void:
	if OS.has_feature("mobile"):
		quit_button.visible = false;
		_on_user_authenticated(GameSettings.userAuthenticated)
		if(GameSettings.signInClient):
			Logging.logMessage("Main menu: sign in client found in game settings! Connecting to user_authenticated.")
			GameSettings.signInClient.user_authenticated.connect(_on_user_authenticated)	
		else: 
			Logging.error("Main menu: No signInClient found in game settings!")
	else:
		quit_button.visible = true;
		if sign_in_button:
			sign_in_button.visible = false
	visible = true
	hide_all()
	buttons.visible = true
	#$Panel2.visible = true
	get_tree().create_timer(0.5).timeout.connect(func():	
		var blackPanelTween = get_tree().create_tween()
		blackPanelTween.set_ease(Tween.EASE_IN)
		blackPanelTween.tween_property($Panel2, "modulate:a", 0, 1.5)
		)
	
	if(!OS.has_feature("mobile")):
		start_button.grab_focus()
	
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
	
	settings_container.visibility_changed.connect(func():
		if settings_container.visible == true:
			settings_back.grab_focus()
			)


##TODO: do we need this method here?
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("MenuCancel") and event.device not in GlobalInputMap.ControllerIds:
		if level_select_screen.visible:
			_on_back_pressed()
		elif ! menu_active:
			reopen_menu_screen()
	
	if menu_active:
		return
	if event.device not in GlobalInputMap.ControllerIds && event.is_action_released("MenuSelect"):
		var index = 0;
		while GlobalInputMap.ControllerIds[index] != -1 && index < 4:
			index += 1;


func start_game() -> void:
	GlobalInputMap.ControllerIds = [0,-1,-1,-1]
	GlobalInputMap.Player_Hats_Selected[0] = 0
	GlobalInputMap.Player_Color_Selected[0] = 0
	GlobalInputMap.Player_Controls_Selected[0] = true
	GameSettings.startGame()
	queue_free()


func menu_out():
	$Logo.visible = false
	start_button.visible = false
	quit_button.visible = false


func _on_user_authenticated(is_authenticated: bool) -> void:
	Logging.logMessage("Main menu: On user authenticated: " + str(is_authenticated))
	sign_in_button.visible = !is_authenticated
	
	
func _on_start_button_pressed() -> void:
	open_level_select()
	
	
func open_level_select():
	level_buttons.get_children()[0].grab_focus()
	hide_all()
	level_select_screen.visible = true
	
	
func _on_settings_pressed() -> void:
	hide_all()
	settings_container.visible = true


func _on_back_pressed() -> void:
	hide_all()
	buttons.visible = true


func _on_map_selected(scene:Map): 
	level_selected_sound.play()
	GameSettings.currentMap = scene
	menu_deactivated()
	start_game()


func _on_quit_pressed() -> void:
	get_tree().quit();


func reopen_menu_screen():
	menu_active = true
	#buttons.visible = true
	hide_all()
	level_select_screen.visible = true
	level_buttons.get_children()[0].grab_focus()
#	start_button.grab_focus()
	
func menu_deactivated() -> void:
	hide_all()
	menu_active = false


func hide_all() -> void:
	buttons.visible = false
	level_select_screen.visible = false
	settings_container.visible = false


func _on_sign_in_pressed() -> void:
	if(GameSettings.signInClient):
		Logging.logMessage("Main menu: Signing in")
		GameSettings.signInClient.sign_in()
	pass # Replace with function body.


func _on_leaderboard_pressed() -> void:
	GameSettings.showAllLeaderboards()
