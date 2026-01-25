extends MainMenu

@export var playerSlots: Array[PlayerSlot]

const ARENA = preload("uid://sctscfmi6mda")

@onready var player_slots_container: HBoxContainer = $PlayerSlots
@onready var game_settings_container: Panel = $GameSettingsContainer


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

func _on_start_button_pressed() -> void:
	open_game_settings()

func open_game_settings() -> void:
	hide_all()
	game_settings_container.visible = true

func _on_back_pressed() -> void:
	hide_all()
	game_settings_container.visible = true

func _on_map_selected(scene:Map): 
	level_selected_sound.play()
	GameSettings.currentMap = scene
	menu_deactivated()

func menu_deactivated() -> void:
	hide_all()
	menu_active = false
	player_slots_container.visible = true

func hide_all() -> void:
	super()
	player_slots_container.visible = false
	game_settings_container.visible = false

func _on_game_settings_start_button_pressed() -> void:
	open_level_select()

func _on_game_settings_back_pressed() -> void:
	hide_all()
	buttons.visible = true
	start_button.grab_focus()
