extends VBoxContainer

@onready var music_mute: Button = $MusicMute
@onready var sfx_mute: Button = $SFXMute
@onready var hold_controls: CheckBox = $Controls/HoldControls
@onready var tap_controls: CheckBox = $Controls/TapControls

@onready var music_checkbox: CheckBox = $MusicCheckbox
@onready var sfx_checkbox: CheckBox = $SFXCheckbox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_mute.set_pressed_no_signal(GameSettings.musicMuted)
	sfx_mute.set_pressed_no_signal(GameSettings.sfxMuted)
	hold_controls.set_pressed_no_signal(GameSettings.holdControls)
	tap_controls.set_pressed_no_signal(!GameSettings.holdControls)
	

func _on_music_mute_toggled(toggled_on: bool) -> void:
	GameSettings.setMusicMuted(toggled_on)

func _on_sfx_mute_toggled(toggled_on: bool) -> void:
	GameSettings.setSFXMuted(toggled_on)

func _on_hold_controls_toggled(toggled_on: bool) -> void:
	GameSettings.setControls(toggled_on)
