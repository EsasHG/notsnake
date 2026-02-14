extends Area2D


func _on_area_entered(area: Area2D) -> void:
	if(area.is_in_group("PlayerHead")):
		Logging.logMessage("Present picked up!")
		if not GlobalInputMap.Player_Hats["SANTA"].unlocked:
			GameSettings.on_somethingUnlocked.emit("SANTA")
			GlobalInputMap.Player_Hats["SANTA"].unlocked = true
			SaveManager.save_unlocks()
			GameSettings.unlock_achievement("Dapper dog")
		GlobalInputMap.Player_Hats_Selected[0] = "SANTA"
		GameSettings.on_dogHatChanged.emit("SANTA")
		queue_free()
pass # Replace with function body.
