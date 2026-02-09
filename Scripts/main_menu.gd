extends Control

class_name MainMenu

var menu_active = true;
const SETTINGS_SCREEN = preload("uid://b2gf7obd6wwhk")
const LOCKED_ICON = preload("uid://bq331b3dfslw5")

@onready var buttons: HBoxContainer = $MainButtons
@onready var level_select_screen: Control = $LevelSelectScreen
@onready var level_buttons: HFlowContainer = $LevelSelectScreen/VBoxContainer/PanelContainer/LevelButtons
@onready var level_selected_sound: AudioStreamPlayer = get_tree().root.find_child("LevelSelected", true, false)
@onready var level_select_back: Button = $LevelSelectScreen/VBoxContainer/ButtonContainer/Back
@onready var start_button: Button = $MainButtons/Start
@onready var quit_button: Button = $MainButtons/Quit
@onready var sign_in_button: Button = $"MainButtons/Sign In"
@onready var settings_button: Button = $MainButtons/Settings
@onready var locked_message_container: PanelContainer = $LockedMessageContainer
@onready var locked_message_description: Label = $LockedMessageContainer/VBoxContainer/DescriptionLabel


@export var buttonTheme:Theme
@export var levels : Array[Map]


func _ready() -> void:
	UINavigator.open.call_deferred(buttons,false)
	
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
		start_button.grab_focus(true)
	visible = true
	buttons.visible = true
	locked_message_container.visible = false
	get_tree().create_timer(0.5).timeout.connect(func():	
		var blackPanelTween = get_tree().create_tween()
		blackPanelTween.set_ease(Tween.EASE_IN)
		blackPanelTween.tween_property($Panel2, "modulate:a", 0, 1.5)
		)
	
	start_button.visibility_changed.connect(func(): 
			if start_button.visible:
				start_button.grab_focus(true)
			)
	level_buttons.visibility_changed.connect(func():
			if level_buttons.visible:
				level_buttons.get_child(0).grab_focus(true)
				)
	
	var music = get_tree().root.find_child("BGMusic", true, false)
	if(music):
		music.play()
	
	for s : Map in levels:
		var map_info = GlobalInputMap.Maps[s.name]

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
		
		if !map_info.unlocked: ##TODO: add actual logic here
			var locked = LOCKED_ICON.instantiate()
			button.add_child(locked)
			button.pressed.connect(_on_locked_map_selected.bind(s))
		else:
			button.pressed.connect(_on_map_selected.bind(s))
		

##TODO: do we need this method here?
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("MenuCancel") and event.device not in GlobalInputMap.ControllerIds:
		if level_select_screen.visible:
			UINavigator.back()
		elif ! menu_active:
			menu_active = true
	if menu_active:
		return
	if event.device not in GlobalInputMap.ControllerIds && event.is_action_released("MenuSelect"):
		var index = 0;
		while GlobalInputMap.ControllerIds[index] != -1 && index < 4:
			index += 1;


func start_game() -> void:
	GlobalInputMap.ControllerIds = [0,-1,-1,-1]
	GlobalInputMap.Player_Color_Selected[0] = 0
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
	#hide_all()
	UINavigator.open(level_select_screen,true)
	

func _on_settings_pressed() -> void:
	UINavigator.open_from_scene(SETTINGS_SCREEN)


func _on_map_selected(scene:Map): 
	level_selected_sound.play()
	GameSettings.currentMap = scene
	menu_active = false
	start_game()


func _on_locked_map_selected(scene:Map):
	UINavigator.open(locked_message_container)
	locked_message_description.text = tr(scene.name + "_UNLOCK_CONDITION")
	
	

func _on_quit_pressed() -> void:
	get_tree().quit();


func _on_sign_in_pressed() -> void:
	if(GameSettings.signInClient):
		Logging.logMessage("Main menu: Signing in")
		GameSettings.signInClient.sign_in()
	pass # Replace with function body.


func _on_leaderboard_pressed() -> void:
	GameSettings.showAllLeaderboards()
