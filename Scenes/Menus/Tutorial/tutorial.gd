extends Control
@onready var popup_menu: PopupContainer = $PopupMenu

var current_message: int  = 1

func _ready() -> void:
	popup_menu.title.visible = false
	popup_menu.description.text = tr("TUTORIAL_1")
	UINavigator.open.call_deferred(popup_menu,false,false,popup_closed)
	
	
func popup_closed() -> void:
	if (current_message < 9):
		current_message+=1
		popup_menu.description.text = tr("TUTORIAL_" + str(current_message))
		if current_message == 5:
			GameSettings.players[0].arrow.visible = true
			GameSettings.on_pickup.connect(popup_closed)
			UINavigator.open(popup_menu,false,true)
		elif current_message == 6:
			UINavigator.force_back()
			GameSettings.on_pickup.disconnect(popup_closed)
			UINavigator.open(popup_menu,false,false,popup_closed)
		else:
			UINavigator.open(popup_menu,false,false,popup_closed)
	else:
		UINavigator.back()
