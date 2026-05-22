extends Node

var achievementsClient : PlayGamesAchievementsClient = null
var achievementsCache: Array[PlayGamesAchievement]

func setup() -> void:
	achievementsClient = get_tree().root.find_child("PlayGamesAchievementsClient", true, false)
	if(achievementsClient):
		achievementsClient.achievements_loaded.connect(_on_achievements_loaded)
		achievementsClient.load_achievements(true)
	else:
		Logging.error("No achievement client found!")


func unlock_achievement(achievementName:String):
	if GameSettings.userAuthenticated and achievementsClient and achievementsCache.size()>0:
		var ach: PlayGamesAchievement = _get_achievement(achievementName)
		if ach.state != PlayGamesAchievement.State.STATE_UNLOCKED: 
			Logging.logMessage("Score is high enough for achievement! Unlocking achievement " + ach.achievement_name)
			achievementsClient.unlock_achievement(ach.achievement_id)
		else:
			Logging.logMessage("Score is high enough for achievement, and achievement is already unlocked! " + ach.achievement_name)

#Should probably do something like save achievement unlocks and progress locally, 
#so we can instantly unlock things if players authenticate after playing for a while?

func increment_achievement(achievementName:String, amount:int):
	if GameSettings.userAuthenticated and achievementsClient and achievementsCache.size()>0:
		var ach:PlayGamesAchievement = _get_achievement(achievementName)
		if ach.state != PlayGamesAchievement.State.STATE_UNLOCKED:
			Logging.logMessage("Incrementing achievement " + ach.achievement_name)
			achievementsClient.increment_achievement(ach.achievement_id, amount)



func _on_achievements_loaded(achievements: Array[PlayGamesAchievement]) -> void:
	Logging.logMessage("Achievements loaded!")
	achievementsCache = achievements
	for map_name in GlobalInputMap.Maps:
		if GlobalInputMap.Maps[map_name].high_score >= 20:
			unlock_achievement(map_name)
			

func show_achievements():
	if(achievementsClient):
		Logging.logMessage("Showing achievements")
		achievementsClient.show_achievements()


func _get_achievement(achievementName:String) -> PlayGamesAchievement:
		var achievementNum = achievementsCache.find_custom(func(a:PlayGamesAchievement): return a.achievement_name.contains(achievementName))
		return achievementsCache[achievementNum]
