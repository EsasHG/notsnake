extends RichTextLabel
const GODOT_ICON = preload("uid://dmhcqqm8tiq0x")

func _ready() -> void:
	text = tr("MADE_IN_GODOT") + " "
	add_image(GODOT_ICON,64,64)
