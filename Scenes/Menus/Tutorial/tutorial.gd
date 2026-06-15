extends Control
@onready var popup_menu: PopupContainer = $PopupMenu
@onready var next_button: Button = $PopupMenu/OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/HBoxContainer/NextButton
@onready var panel: Panel = $PopupMenu/OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/HBoxContainer/Panel
@onready var back_button: Button = $PopupMenu/OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/HBoxContainer/BackButton

var current_message: int  = 1

func _ready() -> void:
	panel.visible = true
	back_button.visible = true
	popup_menu.title.visible = false
	popup_menu.description.text = tr("TUTORIAL_1")
	UINavigator.open.call_deferred(popup_menu,false,true)
	GameSettings.on_viewportChanged.connect(_on_viewport_changed)
	
	
func _on_viewport_changed() -> void:
	match GameSettings.viewport_mode:
		GameSettings.VIEWPORT_MODE.PORTRAIT:
			set_anchors_preset(PRESET_CENTER_TOP)
			pass
		GameSettings.VIEWPORT_MODE.LANDSCAPE:
			set_anchors_preset(PRESET_CENTER_RIGHT)
			pass


func _on_next_button_pressed() -> void:
	back_button.visible = true
	if (current_message < 9):
		current_message+=1
		popup_menu.description.text = tr("TUTORIAL_" + str(current_message))
		match current_message:
			1:
				back_button.visible = false
				panel.visible = true
			2:
				back_button.visible = true
				panel.visible = false
			5:
				next_button.visible = false
				GameSettings.players[0].arrow.visible = true
				GameSettings.on_pickup.connect(_on_next_button_pressed)
				panel.visible = true
				
			6:
				#UINavigator.force_back()
				panel.visible = false
				
				next_button.visible = true
				GameSettings.on_pickup.disconnect(_on_next_button_pressed)
			9:
				next_button.text = tr("CLOSE")
		#UINavigator.open(popup_menu,false,true)
	else:
		queue_free()


func _on_back_button_pressed() -> void:
	next_button.visible = true
	
	if (current_message > 1):
		current_message-=1
		popup_menu.description.text = tr("TUTORIAL_" + str(current_message))
		match current_message:
			1:
				panel.visible = true
				back_button.visible = false
			5:
				GameSettings.players[0].arrow.visible = true
				GameSettings.on_pickup.connect(_on_next_button_pressed)
			4:
				#UINavigator.force_back()
				GameSettings.on_pickup.disconnect(_on_next_button_pressed)
			8:
				next_button.text = tr("NEXT")
