extends GameOverScreen

class_name  ArenaGameOverScreen

@onready var winner_label: Label = $PlacementsContainer/WinnerLabel
@onready var score_label_winner: Label = $PlacementsContainer/ScoreLabelWinner
@onready var place_2: Label = $"PlacementsContainer/2ndPlaceContainer/Place_2"
@onready var place_3: Label = $"PlacementsContainer/3rdPlaceContainer/Place_3"
@onready var place_4: Label = $"PlacementsContainer/4thPlaceContainer/Place_4"

var placements: Dictionary 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"PlacementsContainer/2ndPlaceContainer".visible = false
	$"PlacementsContainer/3rdPlaceContainer".visible = false
	$"PlacementsContainer/4thPlaceContainer".visible = false
	super()
	
	
func game_over(players:Array[PlayerDog]):
	Logging.logMessage("Game over!")
	match GameSettings.game_mode:
		GameSettings.GAME_MODE.LAST_DOG_STANDING:
			Logging.logMessage("Last dog Standing!")
			if players.size() == 1:
				
				var sorted_keys = GlobalInputMap.Player_Placement.keys()
				sorted_keys.sort_custom(func(a, b):
					return GlobalInputMap.Player_Placement[b] > GlobalInputMap.Player_Placement[a]
					)
				var i = 0
				for p in sorted_keys:
					placements[i] = { "Player": p, "Score": -1 }
					i+=1
					
		GameSettings.GAME_MODE.TIME:
			Logging.logMessage("Time!")
			if players.size() > 0:
				players.sort_custom(func(a:PlayerDog,b:PlayerDog):
					return a.score > b.score;
					)
				var i = 0
				for p in players:
					placements[i] = { "Player": p.playerID, "Score": p.score }
					i+=1
				
		GameSettings.GAME_MODE.SCORE:
			if players.size() > 0:
				var sorted_keys = GlobalInputMap.Player_Score.keys()
				
				sorted_keys.sort_custom(func(a, b):
					return GlobalInputMap.Player_Score[a.playerID] > GlobalInputMap.Player_Score[b.playerID]
					)
				var i = 0
				for p in sorted_keys:
					placements[i] = { "Player": p, "Score": GlobalInputMap.Player_Score[p] }
					i+=1
	
	for p in placements:
		if p == 0:
			set_label_text(winner_label, placements[p]["Player"], placements[p]["Score"])
			
			winner_label.text = "Player " + str(placements[p]["Player"]+1) + " won!"
			if GameSettings.game_mode != GameSettings.GAME_MODE.LAST_DOG_STANDING:
				score_label_winner.text = "Score: " + str(placements[p]["Score"])
				score_label_winner.visible = true
				score_label_winner.add_theme_color_override("font_color", 
					GlobalInputMap.player_colors[GlobalInputMap.Player_Color_Selected[placements[p]["Player"]]])
				
			else:
				score_label_winner.visible = false
		else:
			match p:
				1:
					set_label_text(place_2, placements[p]["Player"], placements[p]["Score"])
				2:
					set_label_text(place_3, placements[p]["Player"], placements[p]["Score"])
				3:
					set_label_text(place_4, placements[p]["Player"], placements[p]["Score"])
	$WinnerTex.visible = true


func set_label_text(l:Label, player:int, score:int) -> void:
	l.add_theme_color_override("font_color", GlobalInputMap.player_colors[GlobalInputMap.Player_Color_Selected[player]])
	if score > -1:
		l.text = "Player " + str(player+1) + ". Score: " + str(score) 
	else:
		l.text = "Player " + str(player+1)
	
	l.visible = true
	l.get_parent().visible = true
	visible = true
