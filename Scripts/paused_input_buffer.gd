extends Node2D

func _unhandled_input(event: InputEvent) -> void:
	
	#event.is_action_pressed()
	if(event.is_action("Press") && GameSettings.holdControls):
		if(event.is_pressed()):
			get_parent().rotateRight = true
		else:
			get_parent().rotateRight = false
			
