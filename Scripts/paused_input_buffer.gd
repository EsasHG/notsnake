extends Node2D

func _unhandled_input(event: InputEvent) -> void:
	
	#event.is_action_pressed()
	if(event.is_action("Press") && GlobalInputMap.Player_Controls_Selected[0]):
		if(event.is_pressed()):
			get_parent().rotateRight = true
		else:
			get_parent().rotateRight = false
			
