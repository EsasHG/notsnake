extends Label


func _ready() -> void:
	text = tr("VERSION") + ": " + ProjectSettings.get_setting("application/config/version")
