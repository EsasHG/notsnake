extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _on_resume_pressed() -> void:
	
	$Panel.visible = false
	$Countdown.visible = true
	var tween = CreateCountdownTween()
	
	$Countdown.text = "3"
	tween.tween_callback(func():
		$Countdown.text = "2"
		$Countdown.scale = Vector2(2,2)
		$Countdown.modulate.a = 1
		var t2 = CreateCountdownTween()
		t2.tween_callback(func():
			$Countdown.text = "1"
			$Countdown.scale = Vector2(2,2)
			$Countdown.modulate.a = 1
			
			var t1 = CreateCountdownTween()
			t1.tween_callback(func():
				$Countdown.text = "Loop!"
				$Countdown.scale = Vector2(2,2)
				$Countdown.modulate.a = 1
				
				var tGo = CreateCountdownTween()
				get_tree().paused = false
				tGo.tween_callback(func():
					queue_free()
				)
			)
		)
	)

func CreateCountdownTween():
	$Countdown.visible = true
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Countdown, "modulate:a", 0, 1.0).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($Countdown,"scale", Vector2(25,25),1.0).set_ease(Tween.EASE_IN)
	return tween


func _on_main_menu_pressed() -> void:
	GameSettings.mainMenu()
	get_tree().paused = false
	queue_free()
