extends PopupContainer

@export var language_cylce_duration = 3.0

@onready var language_buttons: HFlowContainer = $OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/LanguageButtons

signal language_selected

const BUTTON_THEME = preload("uid://caljym4n8ghq8")

var timer : Timer
var locales
var current_locale = 0
func _ready() -> void:
	if GameSettings.language == "automatic":
		timer = Timer.new()
		timer.autostart = true
		timer.timeout.connect(_cycle_language)
		timer.wait_time = language_cylce_duration
		add_child(timer)
	locales = TranslationServer.get_loaded_locales()
	for locale in locales:
		var lang = TranslationServer.get_language_name(locale)
		var button = Button.new()
		button.set_script(AudioButton)
		button.custom_minimum_size.x = 180
		if locale == "nb":
			button.text = "Norsk"
		else:
			button.text = lang
		button.pressed.connect(_set_language.bind(locale))
		button.theme = BUTTON_THEME
		language_buttons.add_child(button)
	

func _set_language(locale) -> void:
	TranslationServer.set_locale(locale)
	GameSettings.language = locale
	language_selected.emit()
	SaveManager.save_game()
	UINavigator.back()
	

func _cycle_language() -> void:
	current_locale = current_locale+1 if current_locale < locales.size()-1 else 0
	TranslationServer.set_locale(locales[current_locale])
