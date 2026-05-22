extends Node

var leaderboardsClient : PlayGamesLeaderboardsClient = null
var scoreBoard : PlayGamesLeaderboard
var leaderboardArray : Array[PlayGamesLeaderboard]

func setup() -> void:
	leaderboardsClient = get_tree().root.find_child("PlayGamesLeaderboardsClient", true, false)
	if leaderboardsClient:
		Logging.logMessage("Finding leaderboards!") 
		leaderboardsClient.all_leaderboards_loaded.connect(_all_leaderboards_loaded)
		leaderboardsClient.score_submitted.connect(_score_submitted)
		leaderboardsClient.score_loaded.connect(_on_player_score_loaded)
		leaderboardsClient.load_all_leaderboards(true)
	else:
		Logging.error("No leaderboards client found!")


func submit_score(map_name: String, score: int) -> void:
	if leaderboardsClient:
		Logging.logMessage("Trying to submit score: " + var_to_str(score))
		var submitted : bool = false
		for board in leaderboardArray:
			if board.leaderboard_id == PlayGamesIDs.leaderboards[map_name]: #why all this...
				scoreBoard = board
				Logging.logMessage("Leaderboard found. Submitting Score: " + var_to_str(score))
				leaderboardsClient.submit_score(scoreBoard.leaderboard_id,score)
				submitted = true
		if !submitted:
			Logging.error("Could not find a leaderboard for map "+ map_name + "! Score was never submitted!")



func show_leaderboard():
	if(leaderboardsClient):
		Logging.logMessage("Showing leaderboard " + scoreBoard.display_name)
		leaderboardsClient.show_leaderboard(scoreBoard.leaderboard_id)
	

func show_all_leaderboards():
	if(leaderboardsClient):
		Logging.logMessage("Showing all leaderboards")
		leaderboardsClient.show_all_leaderboards()



func _all_leaderboards_loaded(leaderboards: Array[PlayGamesLeaderboard]) -> void:
	Logging.logMessage("All leaderboards loaded!")
	if not leaderboards.size() == 0:
		leaderboardArray = leaderboards
		scoreBoard = leaderboardArray.front()
		
		#for board in leaderboardArray:
			#Logging.logMessage("Loading player score for leaderboard " + board.display_name)
			#leaderboardsClient.load_player_score(board.leaderboard_id,PlayGamesLeaderboardVariant.TimeSpan.TIME_SPAN_ALL_TIME,PlayGamesLeaderboardVariant.Collection.COLLECTION_FRIENDS)
	else:
		Logging.error("No leaderboards found!")
	pass # Replace with function body.


func _on_player_score_loaded(leaderboard_id: String, score: PlayGamesLeaderboardScore):
	var leaderboard = leaderboardArray[leaderboardArray.find_custom(func(l:PlayGamesLeaderboard): return l.leaderboard_id == leaderboard_id)]
	Logging.logMessage("Score loaded for leaderboard " + leaderboard.display_name + ". Score: " + score.display_score)
	var map_name = PlayGamesIDs.leaderboards.find_key(leaderboard_id)
	if GlobalInputMap.Maps[map_name].high_score < score.raw_score:
		Logging.warn("Found higher highscore from leaderboard! Overwriting locally saved score of" + str(GlobalInputMap.Maps[map_name].high_score) + " with " + str(score.raw_score))
		GlobalInputMap.Maps[map_name].high_score = score.raw_score
	elif GlobalInputMap.Maps[map_name].high_score > score.raw_score and score.raw_score > 0:
		Logging.warn("Found higher highscore in local save! submitting score of " + str(GlobalInputMap.Maps[map_name].high_score) + " to leaderboard " + leaderboard.display_name)
		leaderboardsClient.submit_score(leaderboard_id,GlobalInputMap.Maps[map_name].high_score)
	if GlobalInputMap.Maps[map_name].high_score >= 20:
		AchievementManager.unlock_achievement(leaderboard.display_name)


func _score_submitted(is_submitted: bool, leaderboard_id: String) -> void:
	if is_submitted:
		Logging.logMessage("Score Submitted for leaderboard "+ leaderboard_id)
		if leaderboardsClient:
			Logging.logMessage("Loading player score for leaderboard " + leaderboard_id)
			leaderboardsClient.load_player_score(leaderboard_id,PlayGamesLeaderboardVariant.TimeSpan.TIME_SPAN_ALL_TIME, PlayGamesLeaderboardVariant.Collection.COLLECTION_PUBLIC)
	else: 
		Logging.error("Score not submitted for leaderboard " +  leaderboard_id)
	pass # Replace with function body.
