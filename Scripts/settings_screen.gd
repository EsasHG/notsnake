extends VBoxContainer

@onready var music_mute: Button = $MusicMute
@onready var sfx_mute: Button = $SFXMute
@onready var hold_controls: CheckBox = $Controls/HoldControls
@onready var tap_controls: CheckBox = $Controls/TapControls

@onready var music_checkbox: CheckBox = $MusicCheckbox
@onready var sfx_checkbox: CheckBox = $SFXCheckbox
@onready var show_log: CheckButton = $ShowLog
@onready var googlePlayButtonsContainer: HBoxContainer = $HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_mute.set_pressed_no_signal(GameSettings.musicMuted)
	sfx_mute.set_pressed_no_signal(GameSettings.sfxMuted)
	hold_controls.set_pressed_no_signal(GameSettings.holdControls)
	tap_controls.set_pressed_no_signal(!GameSettings.holdControls)
	show_log.set_pressed_no_signal(Logging.isLogWindowVisible())
	visibility_changed.connect(_on_visibility_changed)

func _on_music_mute_toggled(toggled_on: bool) -> void:
	GameSettings.setMusicMuted(toggled_on)

func _on_sfx_mute_toggled(toggled_on: bool) -> void:
	GameSettings.setSFXMuted(toggled_on)

func _on_hold_controls_toggled(toggled_on: bool) -> void:
	GameSettings.setControls(toggled_on)


func _on_achievements_button_pressed() -> void:
	GameSettings.showAchievements()

func _on_leaderboards_button_pressed() -> void:
		GameSettings.showAllLeaderboards()

func _on_show_log_toggled(toggled_on: bool) -> void:
	Logging.showLogWindow(toggled_on)

func _on_visibility_changed():
	googlePlayButtonsContainer.visible = GameSettings.userAuthenticated


func _on_show_framerate_toggled(toggled_on: bool) -> void:
	var node = get_tree().root.find_child("FPS_Tracker",true, false)
	node.visible = toggled_on
	pass # Replace with function body.
