extends Control

class_name MainMenu

var menu_active = true;
const SETTINGS_SCREEN = preload("uid://b2gf7obd6wwhk")
const LOCKED_ICON = preload("uid://bq331b3dfslw5")

@export var sign_in_button: AudioButton 
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


func _ready() -> void:
	UINavigator.open.call_deferred(buttons,false, true)
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
	buttons.visible = true
	level_select_container.visible = false
	locked_message_container.visible = false
	tutorial_question_container.visible = false
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
	#
	#var audioManager = get_tree().root.find_child("Audio", true, false)
	#if(audioManager):
		#audioManager.startMusic()
	create_level_buttons()
	GameSettings.on_viewportChanged.connect(_on_viewport_changed)
	_on_viewport_changed()

func create_level_buttons() -> void:
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
		button.custom_minimum_size = Vector2(180,180)
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.mouse_filter = Control.MOUSE_FILTER_PASS
		level_buttons.add_child(button)
		
		if !map_info.unlocked: ##TODO: add actual logic here
			var locked = LOCKED_ICON.instantiate()
			button.add_child(locked)
			button.pressed.connect(_on_locked_map_selected.bind(map_name))
		else:
			button.pressed.connect(_on_map_selected.bind(map_name))


func _on_viewport_changed() -> void:
	if GameSettings.viewport_mode == GameSettings.VIEWPORT_MODE.PORTRAIT:
		logo.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP,Control.PRESET_MODE_KEEP_SIZE)
		logo.position.y += 50
		buttons.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM,Control.PRESET_MODE_KEEP_SIZE)
		buttons.position.y -= 160
		#buttons.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	
	else:
		logo.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT,Control.PRESET_MODE_KEEP_SIZE)
		logo.position.y += 50
		buttons.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT,Control.PRESET_MODE_KEEP_SIZE)
		#buttons.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
		buttons.position.x -= 160

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


func _on_locked_map_selected(map_name:String):
	UINavigator.open(locked_message_container)
	locked_message_description.text = tr(map_name + "_UNLOCK_CONDITION")
	

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
