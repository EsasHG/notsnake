extends VBoxContainer

class_name AdLayout
@onready var ad_panel: Panel = $AdPanel

func _ready() -> void:
	if GameSettings.adManager and GameSettings.adManager.admob:
		GameSettings.adManager.admob.banner_ad_opened.connect(_show_banner_panel)
		GameSettings.adManager.admob.banner_ad_closed.connect(_hide_banner_panel)
		GameSettings.on_banner_ad_changed.connect(_on_banner_ad_changed)
		if GameSettings.adManager.banner_ad_showing:
			_show_banner_panel()
		else:
			_hide_banner_panel()
	else:
		_hide_banner_panel()
		

func _on_banner_ad_changed() -> void:
	Logging.logMessage("Banner ad changed!")
	_show_banner_panel()
 
func _show_banner_panel() -> void:
	var banner_y = GameSettings.adManager.banner_ad_size.y
	if banner_y > 0:
		ad_panel.custom_minimum_size.y = GameSettings.adManager.banner_ad_size.y
	ad_panel.visible = true


func _hide_banner_panel() -> void:
	ad_panel.visible = false
