extends Control

class_name MainMenu

var menu_active = true
var show_from_start = false
const SETTINGS_SCREEN = preload("uid://b2gf7obd6wwhk")
const LOCKED_ICON = preload("uid://bq331b3dfslw5")

@export var sign_in_button: TextureButton 
@onready var tutorial_question_container: PanelContainer = $AdLayoutContainer/TutorialQuestionContainer
@onready var buttons: VBoxContainer = $MainButtons
@onready var level_select_container: PanelContainer = $AdLayoutContainer/LevelSelectContainer
@onready var level_buttons: HFlowContainer = $AdLayoutContainer/LevelSelectContainer/ScrollContainer/InnerContainer/VBoxContainer/LevelButtons
@onready var level_selected_sound: AudioStreamPlayer = get_tree().root.find_child("LevelSelected", true, false)
@onready var start_button: Button = $MainButtons/Start
@onready var settings_button: Button = $MainButtons/Settings
@onready var quit_button: Button = $MainButtons/Quit
@onready var locked_message_container: PanelContainer = $AdLayoutContainer/LockedMessageContainer
@onready var locked_message_description: Label = $AdLayoutContainer/LockedMessageContainer/ScrollContainer/InnerContainer/VBoxContainer/DescriptionLabel
@onready var logo: TextureRect = $Logo

@export var buttonTheme:Theme
## TODO: Use global input map instead of this...
@export var levels : Array[Map]
@export var level_buttons_size : float:
	set(new_value):
		level_buttons_size = new_value
		create_level_buttons()
		
@export var feedback_link : String

func _ready() -> void:
	GameSettings.on_gameBegin.connect(queue_free)
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
	level_select_container.visible = false
	locked_message_container.visible = false
	tutorial_question_container.visible = false
	logo.visible = true
	
	
	start_button.visibility_changed.connect(func(): 
			if start_button.visible:
				start_button.grab_focus(true)
			)
	level_buttons.visibility_changed.connect(func():
			if level_buttons.visible:
				level_buttons.get_child(0).grab_focus(true)
				)
	create_level_buttons()
	GameSettings.on_languageSelected.connect(create_level_buttons)
	GameSettings.on_viewportChanged.connect(_on_viewport_changed)
	buttons.visibility_changed.connect(func(): 
		if OS.has_feature("mobile") and !GameSettings.userAuthenticated: 
			sign_in_button.visible = buttons.visible
			)
	_on_viewport_changed()
	check_play_in_animations.call_deferred()
	
func check_play_in_animations() -> void:
	if show_from_start:
		buttons.visible = true
	else:
		buttons.visible = false
		logo.scale = Vector2(0.3,0.3)
		var tween_length : float = 0.35 
		var logo_tween : Tween = get_tree().create_tween()
		logo_tween.set_ease(Tween.EASE_OUT)
		logo_tween.tween_property(logo,"scale",Vector2(1,1),tween_length).set_trans(Tween.TRANS_BACK)
		await get_tree().create_timer(0.15).timeout
		buttons.visible = true
		buttons.scale = Vector2(0.3,0.3)
		var button_tween : Tween = get_tree().create_tween()
		button_tween.set_ease(Tween.EASE_OUT)
		button_tween.tween_property(buttons,"scale",Vector2(1,1),tween_length).set_trans(Tween.TRANS_BACK)
		button_tween.finished.connect(UINavigator.open.bind(buttons,false, true))
		

func create_level_buttons() -> void:
	if !level_buttons:
		return
	for c in level_buttons.get_children():
		c.queue_free()
	for map_name: String in GlobalInputMap.Maps:
		var map_info :Dictionary = GlobalInputMap.Maps[map_name]

		var button : Button = Button.new()
		button.theme = buttonTheme
		button.icon = map_info.icon
		button.text = tr(map_name)
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.expand_icon = true
		button.custom_minimum_size = Vector2(level_buttons_size,level_buttons_size)
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.mouse_filter = Control.MOUSE_FILTER_PASS
		level_buttons.add_child(button)
		
		if !map_info.unlocked: ##TODO: add actual logic here
			var locked = LOCKED_ICON.instantiate() as Container
			button.add_child(locked)
			locked.custom_minimum_size = button.custom_minimum_size
			button.pressed.connect(_on_locked_map_selected.bind(map_name))
		else:
			button.pressed.connect(_on_map_selected.bind(map_name))


func _on_viewport_changed() -> void:
	if GameSettings.viewport_mode == GameSettings.VIEWPORT_MODE.PORTRAIT:
		logo.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP,Control.PRESET_MODE_KEEP_SIZE)
		logo.position.y += 50
		buttons.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM,Control.PRESET_MODE_KEEP_SIZE)
		buttons.position.y -= 300
		#buttons.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	else:
		logo.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT,Control.PRESET_MODE_KEEP_SIZE)
		logo.position.y += 50
		buttons.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT,Control.PRESET_MODE_KEEP_SIZE)
		#buttons.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
		buttons.position.x -= 100

##TODO: do we need this method here?
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("MenuCancel") and event.device not in GlobalInputMap.ControllerIds:
		if level_select_container.visible:
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
	if not GameSettings.play_tutorial:
		open_level_select()
	else:
		UINavigator.open(tutorial_question_container)

func open_level_select():
	level_buttons.get_children()[0].grab_focus()
	UINavigator.open(level_select_container,true)
	

func _on_settings_pressed() -> void:
	UINavigator.open_from_scene(SETTINGS_SCREEN)


func _on_map_selected(map_name:String): 
	level_selected_sound.play()
	GameSettings.currentMap = map_name
	menu_active = false
	start_game()


func _on_locked_map_selected(_map_name:String):
	UINavigator.open(locked_message_container)
	locked_message_description.text = tr("MAP_UNLOCK_CONDITION")
	

func _on_quit_pressed() -> void:
	get_tree().quit();


func _on_sign_in_pressed() -> void:
	if(GameSettings.signInClient):
		Logging.logMessage("Main menu: Signing in")
		GameSettings.signInClient.sign_in()
	pass # Replace with function body.


func _on_leaderboard_pressed() -> void:
	LeaderboardManager.showAllLeaderboards()


func _on_tutorial_yes_pressed() -> void:
	level_selected_sound.play()
	GameSettings.currentMap = "FIELD"
	menu_active = false
	start_game()


func _on_no_pressed() -> void:
	UINavigator.back()
	GameSettings.play_tutorial = false
	open_level_select()
	pass # Replace with function body.


func _on_feedback_pressed() -> void:
	OS.shell_open(feedback_link)
	pass # Replace with function body.
