extends VBoxContainer

@onready var music_mute: AudioButton = $SoundButtons/MusicMute
@onready var sfx_mute: AudioButton = $SoundButtons/SFXMute
@onready var hold_controls: CheckBox = $Controls/HoldControls
@onready var tap_controls: CheckBox = $Controls/TapControls

@onready var googlePlayButtonsContainer: HBoxContainer = $HBoxContainer
@onready var language_selector: OptionButton = $Controls/VBoxContainer/LanguageSelector

const SKIN_SELECTOR = preload("uid://cwe8t3lvlv7ki")
const DEBUG_SETTINGS_CONTAINER = preload("uid://d0dfdlrxfu8iw")

var _changes_made = false

func _ready() -> void:
	music_mute.set_pressed_no_signal(GameSettings.musicMuted)
	sfx_mute.set_pressed_no_signal(GameSettings.sfxMuted)
	hold_controls.set_pressed_no_signal(GlobalInputMap.Player_Controls_Selected[0])
	tap_controls.set_pressed_no_signal(!GlobalInputMap.Player_Controls_Selected[0])
	
	visibility_changed.connect(_on_visibility_changed)
	if OS.has_feature("mobile") and GameSettings.userAuthenticated:
		googlePlayButtonsContainer.visible = true
	else:
		googlePlayButtonsContainer.visible = false
	
	language_selector.clear()
	for locale in TranslationServer.get_loaded_locales():
		## the method below returned "Norwegian bokmål" for "nb", and that didn't feel right to me.
		var lang = TranslationServer.get_language_name(locale)
		if locale == "nb":
			language_selector.add_item("Norsk")	
		else:
			language_selector.add_item(lang)
			
		if GameSettings.language == locale:
			language_selector.select(language_selector.item_count-1)
			
	GameSettings.on_dogColorChanged.connect(_on_color_changed)
	GameSettings.on_dogHatChanged.connect(_on_hat_changed)


func _on_music_mute_toggled(toggled_on: bool) -> void:
	GameSettings.setMusicMuted(toggled_on)
	_changes_made = true

func _on_sfx_mute_toggled(toggled_on: bool) -> void:
	GameSettings.setSFXMuted(toggled_on)
	_changes_made = true


func _on_hold_controls_toggled(toggled_on: bool) -> void:
	GameSettings.setControls(toggled_on)
	_changes_made = true


func _on_achievements_button_pressed() -> void:
	GameSettings.showAchievements()


func _on_leaderboards_button_pressed() -> void:
	GameSettings.showAllLeaderboards()


func _on_visibility_changed():
	if OS.has_feature("mobile"):
		googlePlayButtonsContainer.visible = GameSettings.userAuthenticated


func _on_back_pressed() -> void:
	if _changes_made:
		SaveManager.save_settings()
	UINavigator.back()
	pass # Replace with function body.


func _on_language_selector_item_selected(index: int) -> void:
	var locale = TranslationServer.get_loaded_locales()[index]
	TranslationServer.set_locale(locale)
	GameSettings.language = locale
	_changes_made = true


func _on_skin_select_pressed() -> void:
	UINavigator.open_from_scene(SKIN_SELECTOR)
	pass # Replace with function body.


func _on_color_changed(_col: Color):
	_changes_made = true


func _on_hat_changed(_hat: String):
	_changes_made = true


func _on_debug_settings_pressed() -> void:
	UINavigator.open_from_scene(DEBUG_SETTINGS_CONTAINER)
