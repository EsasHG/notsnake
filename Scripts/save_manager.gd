extends Node

@onready var snapshotClient : PlayGamesSnapshotsClient = get_tree().root.find_child("PlayGamesSnapshotsClient", true, false)

signal _files_loaded(success:bool)

const SETTINGS_FILE = "settings.save"
const SCORES_FILE = "savegame.save"
const UNLOCKS_FILE = "unlocks.save"

const CONFLICT_POPUP = preload("uid://chylx0i6w8on4")
const POPUP_CONTAINER = preload("uid://b3m2an3pchd8w")
const POPUP_MENU = preload("uid://chupiwnqy5234")
var cloud_save_enabled = true

var _conflict : PlayGamesSnapshotConflict = null
var _force_cloudsave_reload : bool = true

func _ready() -> void:
	#GameSettings.signInClient.user_authenticated.connect(_on_user_authenticated)	
	snapshotClient.snapshots_loaded.connect(_on_snapshots_loaded)
	snapshotClient.game_loaded.connect(_on_game_loaded)
	snapshotClient.game_saved.connect(_on_game_saved)
	snapshotClient.conflict_emitted.connect(_on_conflict)


func show_cloud_saves() -> void:
	if GameSettings.userAuthenticated:
		Logging.logMessage("Showing cloud saves!")
		snapshotClient.show_saved_games("Saves",true,true,3)
	else:
		var popup = UINavigator.open_from_scene(POPUP_MENU)
		popup.title.text = tr("ERROR")
		popup.description.text = tr("CLOUD_SAVES_UNAVALIABLE")


func load_game() -> bool:
	var success: bool = false
	if cloud_save_enabled:
		success = _load_from_cloud()
	if ! success:
		success = _load_from_local()
	return success
		

func save_game() -> void:
	if cloud_save_enabled:
		if not _save_to_cloud():
			_save_to_local()
	else:
		_save_to_local()


func _load_from_cloud() -> bool:
	if snapshotClient:
		snapshotClient.load_snapshots(_force_cloudsave_reload)
		_force_cloudsave_reload = false
		return true
	else:
		Logging.error("snapshotClient is unavaliable! Could not load save file from snapshotClient.")
		return false
		
	
func _load_from_local() -> bool: 
	var result : bool
	var save_file = FileAccess.open("user://cloud_save.save", FileAccess.READ)
	if save_file == null:
		Logging.error("Error opening file: " + error_string(FileAccess.get_open_error()))
		result = false
	else:
		var buffer = save_file.get_buffer(save_file.get_length())
		var node_data : Dictionary = bytes_to_var(buffer)
		_set_settings_save_content(node_data["settings"])
		_set_score_save_content(node_data["scores"])
		_set_unlocks_save_content(node_data["unlocks"])
		result = true
	_files_loaded.emit(result)
	return result
	

func _get_settings_save_content() -> Dictionary:
	var settings = {
		"musicVol" = db_to_linear(GameSettings.musicVol), 
		"sfxVol" = db_to_linear(GameSettings.sfxVol), 
		"musicMuted" = GameSettings.musicMuted, 
		"sfxMuted" = GameSettings.sfxMuted, 
		"controls" = GlobalInputMap.Player_Controls_Selected[0],
		"language" = GameSettings.language,
		"dogColor" = GlobalInputMap.player_colors[0].to_html(),
		"hat" = GlobalInputMap.Player_Hats_Selected[0],
		"times_crashed" = GameSettings.times_crashed,
		} 
	return settings


func _set_settings_save_content(node_data: Dictionary) -> void: 
	if node_data.has("sfxVol"):
		GameSettings.sfxVol = linear_to_db(node_data["sfxVol"])
	else:
		Logging.error("Could not load SFX volume from save file!")
		GameSettings.sfxVol = linear_to_db(0.8)
	if node_data.has("musicVol"):
		GameSettings.musicVol = linear_to_db(node_data["musicVol"])
	else:
		Logging.error("Could not load music volume from save file!")
		GameSettings.musicVol = linear_to_db(0.8)
	if node_data.has("sfxMuted"):
		GameSettings.sfxMuted = node_data["sfxMuted"]
	else:
		Logging.error("Could not load SFX muted from save file!")
		GameSettings.sfxMuted = false
	GameSettings.setSFXMuted(GameSettings.sfxMuted)
	if node_data.has("musicMuted"):
		GameSettings.musicMuted = node_data["musicMuted"]
	else:
		Logging.error("Could not load music muted from save file!")
		GameSettings.musicMuted = false
	GameSettings.setMusicMuted(GameSettings.musicMuted)
	if node_data.has("controls"):
		GameSettings.setControls(node_data["controls"])
	else:
		GameSettings.setControls(true)
	if node_data.has("language"):
		GameSettings.language = node_data["language"]
	if node_data.has("dogColor"):
		GlobalInputMap.player_colors[0] = Color(node_data["dogColor"])
	if node_data.has("hat"):
		GlobalInputMap.Player_Hats_Selected[0] = node_data["hat"]
		GameSettings.on_dogHatChanged.emit(node_data["hat"])
	else: 
		GlobalInputMap.Player_Hats_Selected[0] = "NONE"
	if node_data.has("times_crashed"):
		GameSettings.times_crashed = node_data["times_crashed"]


func _get_score_save_content() -> Dictionary:
	var scores:Dictionary
	for map_name in GlobalInputMap.Maps:
		scores[map_name] = GlobalInputMap.Maps[map_name].high_score
	return scores
	

func _set_score_save_content(node_data: Dictionary) -> void:
	if node_data.has("highScores"):
		for map_name in node_data["highScores"]:
			if GlobalInputMap.Maps.has(map_name) and GlobalInputMap.Maps[map_name].high_score < node_data["highScores"][map_name]:
				GlobalInputMap.Maps[map_name].high_score = node_data["highScores"][map_name]


func _get_unlocks_save_content() -> Dictionary:
	##Find unlocked maps
	var unlocked_maps :Array[String]
	for map: String in GlobalInputMap.Maps:
		if GlobalInputMap.Maps[map].unlocked:
			unlocked_maps.append(map)
				
	##Find unlocked hats:
	var unlocked_hats : Array[String]
	for hat: String in GlobalInputMap.Player_Hats:
		if GlobalInputMap.Player_Hats[hat].unlocked:
			unlocked_hats.append(hat)
	var unlocks = {
			"unlocked_maps" = unlocked_maps,
			"unlocked_hats" = unlocked_hats,
			} 
	return unlocks


func _set_unlocks_save_content(node_data: Dictionary) -> void:
	if node_data.has("unlocked_maps"):
		var unlocked_maps : Array = node_data["unlocked_maps"]
		for map in unlocked_maps:
			GlobalInputMap.Maps[map].unlocked = true
	
	if node_data.has("unlocked_hats"):
		var unlocked_hats : Array = node_data["unlocked_hats"]
		for hat in unlocked_hats:
			GlobalInputMap.Player_Hats[hat].unlocked = true




func _create_save_content() -> PackedByteArray:
	var settings = _get_settings_save_content()
	var scores = _get_score_save_content()
	var unlocks = _get_unlocks_save_content()
	var save : Dictionary = {
		"settings":settings,
		"scores": scores,
		"unlocks" : unlocks,
	}
	return var_to_bytes(save)
	

func _on_snapshots_loaded(snapshots: Array[PlayGamesSnapshotMetadata]) -> void:
	if snapshots.size() == 1:
		snapshotClient.load_game(snapshots.back().unique_name)
	else:
		Logging.warn("Unexpected snapshot amount in _on_snapshots_loaded! Expected 1, got " + str(snapshots.size()) + ". Looking for locally saved file instead.")
		_load_from_local()
		

func _on_game_loaded(snapshot: PlayGamesSnapshot) -> void:
	var save : Dictionary
	if snapshot == null:
		Logging.warn("Cloud snapshot not found! Looking for locally saved file.")
		_load_from_local()
	else:
		save = bytes_to_var(snapshot.content)
		_set_settings_save_content(save["settings"])
		_set_score_save_content(save["score"])
		_set_unlocks_save_content(save["unlocks"])
		_files_loaded.emit(true)
	

func _save_to_cloud() -> bool:
	var save_bytes:PackedByteArray  = _create_save_content()
	if GameSettings.userAuthenticated and is_instance_valid(snapshotClient):
		##TODO: add time played, and the player's dog as an icon??? that could be cool.
		snapshotClient.save_game("save_1", "Save 1", save_bytes)
		return true
	else:
		Logging.error("snapshotClient is unavaliable!")
		return false
		

func _on_game_saved(is_saved: bool, save_data_name: String, save_data_description: String) -> void:
	Logging.logMessage("Game saved emitted!")
	if is_saved:
		Logging.logMessage("Game saved to file " + save_data_name + " with description " + save_data_description)
	else:
		Logging.error("Game not saved! Saving file locally")
		_save_to_local()
		

func _save_to_local() -> void:
	var save_bytes:PackedByteArray  = _create_save_content()
	var save_file = FileAccess.open("user://cloud_save.save", FileAccess.WRITE)
	save_file.store_buffer(save_bytes)

	
func _on_conflict(conflict: PlayGamesSnapshotConflict) -> void:
	Logging.error("Cloud save conflict!")
	_conflict = conflict
	var popup: ConflictPopup  = UINavigator.open_from_scene(CONFLICT_POPUP)
	popup.local_save_title.text =  conflict.conflicting_snapshot.metadata.description
	var local_modified_time = Time.get_datetime_dict_from_unix_time(conflict.conflicting_snapshot.metadata.last_modified_timestamp)
	popup.local_save_time.text = tr("LAST_MODIFIED") + "\n" +  Time.get_datetime_string_from_datetime_dict(local_modified_time,true)
	popup.choose_local_button.pressed.connect(_local_save_chosen)
	
	popup.server_save_title.text =  conflict.server_snapshot.metadata.description
	var server_modified_time = Time.get_datetime_dict_from_unix_time(conflict.server_snapshot.metadata.last_modified_timestamp)
	popup.server_save_time.text = tr("LAST_MODIFIED") + "\n" +  Time.get_datetime_string_from_datetime_dict(server_modified_time,true)
	popup.choose_server_button.pressed.connect(_server_save_chosen)
	

func _local_save_chosen() -> void:
	Logging.logMessage("User chose to keep local save file!")
	if _conflict == null:
		Logging.error("Trying to resolve conflict with local save, but _conflict is null!")
	else:
		snapshotClient.delete_snapshot(_conflict.server_snapshot.metadata.snapshot_id)		
		var snapshot_to_save : PlayGamesSnapshot 
		if _conflict.origin == "SAVE":
			snapshot_to_save = _conflict.server_snapshot
		else: 
			snapshot_to_save = _conflict.conflicting_snapshot
		snapshotClient.save_game(snapshot_to_save.metadata.unique_name, snapshot_to_save.metadata.description,snapshot_to_save.content)
	

func _server_save_chosen() -> void:
	Logging.logMessage("User chose to keep server save file!")	
	if _conflict == null:
		Logging.error("Trying to resolve conflict with server save, but _conflict is null!")
	else:
		snapshotClient.delete_snapshot(_conflict.conflicting_snapshot.metadata.snapshot_id)
		var snapshot_to_save : PlayGamesSnapshot 
		if _conflict.origin == "SAVE":
			snapshot_to_save = _conflict.server_snapshot
		else: 
			snapshot_to_save = _conflict.conflicting_snapshot
		snapshotClient.save_game(snapshot_to_save.metadata.unique_name, snapshot_to_save.metadata.description,snapshot_to_save.content)
