extends MainMenu

@export var playerSlots: Array[PlayerSlot]

const ARENA = preload("uid://sctscfmi6mda")

@onready var player_slots_container: HBoxContainer = $PlayerSlots
@onready var game_settings_container: Panel = $GameSettingsContainer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("MenuCancel") and event.device not in GlobalInputMap.ControllerIds:
		if level_select_container.visible or game_settings_container.visible:
			UINavigator.back()
		elif ! menu_active:
			UINavigator.back()
			menu_active = true
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
	UINavigator.open(game_settings_container,true)

func open_game_settings() -> void:
	UINavigator.open(game_settings_container,true)

func _on_map_selected(scene:Map): 
	level_selected_sound.play()
	GameSettings.currentMap = scene
	menu_active = false
	UINavigator.open(player_slots_container,true)


func _on_game_settings_start_button_pressed() -> void:
	UINavigator.open(level_select_container,true)
	#open_level_select()
