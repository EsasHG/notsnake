extends Control

@onready var resume: Button = $Panel/VBoxContainer/HBoxContainer2/Resume
const SETTINGS_SCREEN = preload("uid://b2gf7obd6wwhk")
@onready var close_button: Button = $Close



func _ready() -> void:
	visibility_changed.connect(func():
		if visible: 
			resume.grab_focus(true))
	resume.grab_focus(true)


#do we really want this here?
func _on_resume_pressed() -> void:
	$Panel.visible = false
	close_button.visible = false
	next_count(3)
	

func next_count(count : int) -> void:
	$Countdown.scale = Vector2(2,2)
	$Countdown.modulate.a = 1
	
	if count > 0:
		$Countdown.text = str(count)
		var t = create_countdown_tween()
		t.tween_callback(next_count.bind(count-1))
	else:
		$Countdown.text = "Loop!"
		GameSettings.unpause_game()
		var t = create_countdown_tween()
		t.tween_callback(UINavigator.back)


func create_countdown_tween():
	$Countdown.visible = true
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Countdown, "modulate:a", 0, 1.0).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($Countdown,"scale", Vector2(25,25),1.0).set_ease(Tween.EASE_IN)
	return tween


func _on_settings_pressed() -> void:
	UINavigator.open_from_scene(SETTINGS_SCREEN, true)
	pass # Replace with function body.


func _on_end_run_pressed() -> void:
	GameSettings.end_run()
	get_tree().paused = false
	queue_free()
