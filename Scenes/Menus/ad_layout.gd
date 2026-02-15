extends VBoxContainer

class_name AdLayout
@onready var ad_panel: Panel = $AdPanel

func _ready() -> void:
	if GameSettings.adManager and GameSettings.adManager.admob:
		GameSettings.adManager.admob.banner_ad_opened.connect(_show_banner_panel)
		GameSettings.adManager.admob.banner_ad_closed.connect(_hide_banner_panel)
		if GameSettings.adManager.banner_ad_showing:
			_show_banner_panel()
		else:
			_hide_banner_panel()
	else:
		_hide_banner_panel()
		

func _show_banner_panel() -> void:
	ad_panel.visible = true


func _hide_banner_panel() -> void:
	ad_panel.visible = false
