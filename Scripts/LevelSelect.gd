extends Control 
@export var buttonTheme:Theme
@export var scenes : Array[Map]
var currentScene : int = 0

func _ready() -> void:
	for s : Map in scenes:
		print_debug(s.name)
		var button : Button = Button.new()
		button.icon = s.icon
		button.text = s.name
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.expand_icon = true
		button.custom_minimum_size = Vector2(100,100)
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		$PanelContainer/HFlowContainer.add_child(button)
		button.pressed.connect(_on_map_selected.bind(s))

func _on_map_selected(scene:Map): 
	GameSettings.currentMap = scene
	GameSettings.startGame()
	queue_free()
