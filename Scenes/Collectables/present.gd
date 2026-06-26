extends Area2D


func _on_area_entered(area: Area2D) -> void:
	if(area.is_in_group("PlayerHead")):
		Logging.logMessage("Present picked up!")
		if not GlobalInputMap.hats["SANTA"].unlocked:
			GameSettings.on_somethingUnlocked.emit("SANTA")
			GlobalInputMap.hats["SANTA"].unlocked = true
			SaveManager.save_game()
			AchievementManager.unlock_achievement("Dapper dog")
		GlobalInputMap.hats_selected[0] = "SANTA"
		GameSettings.on_dogHatChanged.emit("SANTA")
		queue_free()
pass # Replace with function body.
