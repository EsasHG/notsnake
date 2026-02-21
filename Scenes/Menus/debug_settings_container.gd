extends PanelContainer
@onready var show_log: AudioButton = $DebugScreen/ShowLog

func _ready() -> void:
	show_log.set_pressed_no_signal(Logging.isLogWindowVisible())


func _on_show_framerate_toggled(toggled_on: bool) -> void:
	var node = get_tree().root.find_child("FPS_Tracker",true, false)
	node.visible = toggled_on


func _on_show_log_toggled(toggled_on: bool) -> void:
	Logging.showLogWindow(toggled_on)


func _on_unlock_hats_pressed() -> void:
	for key in GlobalInputMap.Player_Hats:
		GlobalInputMap.Player_Hats[key].unlocked = true


func _on_unlock_maps_pressed() -> void:
	for key in GlobalInputMap.Maps:
		GlobalInputMap.Maps[key].unlocked = true
	var main_menu = get_tree().root.find_child("MainMenu", true,false)
	if not is_instance_valid(main_menu):
		Logging.error("Could not find main menu from debug settings on unlock maps!")
		return
	else:
		main_menu.create_level_buttons()


func _on_lock_hats_pressed() -> void:
	for key in GlobalInputMap.Player_Hats:
		if key != "NONE" and key != "TEST":
			GlobalInputMap.Player_Hats[key].unlocked = false


func _on_lock_maps_pressed() -> void:
	for key in GlobalInputMap.Maps:
		if key != "FIELD":
			GlobalInputMap.Maps[key].unlocked = false
	var main_menu = get_tree().root.find_child("MainMenu", true,false)
	if not is_instance_valid(main_menu):
		Logging.error("Could not find main menu from debug settings on lock maps!")
		return
	else:
		main_menu.create_level_buttons()


func _on_back_pressed() -> void:
	UINavigator.back()
	

func _on_purchase_ad_removal_pressed() -> void:
	if GameSettings.billingManager:
		GameSettings.billingManager.show_ad_removal_popup()
	else:
		Logging.error("Billing manager not found in GameSettings!")

func _on_consume_purchase_pressed() -> void:
	if GameSettings.billingManager:
		GameSettings.billingManager._consume_purchase()
	else:
		Logging.error("Billing manager not found in GameSettings!")
