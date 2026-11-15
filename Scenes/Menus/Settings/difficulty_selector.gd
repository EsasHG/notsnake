extends HBoxContainer

@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_label_text()


func _update_label_text():
	label.text = tr(GameSettings.DIFFICULTY.keys()[GameSettings.difficulty])
	
	
func _on_left_arrow_pressed() -> void:
	var i = GameSettings.difficulty as int
	i-=1;
	if i <0:
		i = GameSettings.DIFFICULTY.values().back()
	GameSettings.difficulty = i as GameSettings.DIFFICULTY
	_update_label_text()


func _on_right_arrow_pressed() -> void:
	var i = GameSettings.difficulty as int
	i+=1;
	if i >= GameSettings.DIFFICULTY.values().size():
		i = GameSettings.DIFFICULTY.values().front()
	GameSettings.difficulty = i as GameSettings.DIFFICULTY
	_update_label_text()
