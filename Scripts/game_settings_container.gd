extends Panel
@onready var lives_container: VBoxContainer = $VBoxContainer/LivesContainer
@onready var time_container: VBoxContainer = $VBoxContainer/TimeContainer

@onready var lives_label: Label = $VBoxContainer/LivesContainer/LivesSelector/LivesLabel
@onready var time_label: Label = $VBoxContainer/TimeContainer/TimeSelector/TimeLabel
@onready var minutes_label: Label = $VBoxContainer/TimeContainer/TimeSelector/Minutes
var current_lives : int
var current_time_minutes : int
var current_time_seconds : int = 60
var display_seconds : bool = false
func _ready() -> void:
	visibility_changed.connect(set_focus)
	_on_option_button_item_selected(GameSettings.game_mode)
	current_lives = GameSettings.lives
	current_time_minutes = GameSettings.round_time_seconds/60
	lives_label.text = str(current_lives)
	_update_time_labels_text()
	
	lives_container.visibility_changed.connect(func(): lives_label.text = str(current_lives))
	time_container.visibility_changed.connect(_update_time_labels_text)
	

func _on_option_button_item_selected(index: int) -> void:
	GameSettings.game_mode = index as GameSettings.GAME_MODE
	
	lives_container.visible = false
	
	match GameSettings.game_mode:
		GameSettings.GAME_MODE.LAST_DOG_STANDING:
			lives_container.visible = true
			time_container.visible = false
		_:
			lives_container.visible = false
			time_container.visible = true
				


func set_focus():
	if visible:
		$VBoxContainer/HBoxContainer/StartButton.grab_focus()


func _on_start_button_pressed() -> void:
	var index = $VBoxContainer/OptionButton.selected
	GameSettings.game_mode = index as GameSettings.GAME_MODE
	GameSettings.lives = current_lives
	GameSettings.round_time_seconds =  current_time_seconds if display_seconds else current_time_minutes*60


func _on_button_minus_pressed() -> void:
	current_lives -=1
	if current_lives <1:
		current_lives = 1
	lives_label.text = str(current_lives)


func _on_button_plus_pressed() -> void:
	current_lives +=1
	if current_lives >99:
		current_lives = 99
	lives_label.text = str(current_lives)
	

func _on_time_button_minus_pressed() -> void:
	if display_seconds:
		current_time_seconds -= 15
		if current_time_seconds < 15:
			current_time_seconds = 15
	else:
		current_time_minutes -=1
		if current_time_minutes <1:
			current_time_minutes = 1
			current_time_seconds = 45
			display_seconds = true
	_update_time_labels_text()
		


func _on_time_button_plus_pressed() -> void:
	if display_seconds:
		current_time_seconds += 15
		if current_time_seconds >= 60:
			display_seconds = false
	else:
		current_time_minutes +=1
	if current_time_minutes >99:
		current_time_minutes = 99
	_update_time_labels_text()
	

func _update_time_labels_text()-> void:
	if display_seconds:
		minutes_label.text = "seconds"
		
	elif current_time_minutes == 1:
		minutes_label.text = "minute"
	else:
		minutes_label.text = "minutes"
	time_label.text = str(current_time_seconds) if display_seconds else str(current_time_minutes)
