extends VBoxContainer
const music_mute_icon: Texture2D = preload("uid://dj5ymgtujgle6")
const music_on_icon: Texture2D = preload("uid://dk1jjkosknlgo")
const sfx_mute_icon: Texture2D = preload("uid://n0icqrejpobn")
const sfx_low_icon: Texture2D = preload("uid://ntdvir0chiwn")
const sfx_med_icon: Texture2D = preload("uid://b3ap7e5h232cl")
const sfx_full_icon: Texture2D =preload("uid://cujin12teacdj")

@onready var music_icon: TextureRect = $Music/MusicIcon
@onready var sfx_icon: TextureRect = $SFX/SFXIcon
@onready var music_slider: HSlider = $Music/MusicSlider
@onready var sfx_slider: HSlider = $SFX/SFXSlider


var _changes_made:bool = false

func _on_music_mute_toggled(toggled_on: bool) -> void:
	GameSettings.setMusicMuted(toggled_on)
	_changes_made = true
	music_slider.value = GameSettings.musicVol
	sfx_slider.value = GameSettings.sfxVol

func _on_sfx_mute_toggled(toggled_on: bool) -> void:
	GameSettings.setSFXMuted(toggled_on)
	_changes_made = true


func _on_music_slider_value_changed(value: float) -> void:
	if value <= 0: 
		GameSettings.setSFXMuted(true)
		music_icon.texture = music_mute_icon
	else:
		GameSettings.setSFXMuted(false)
		music_icon.texture = music_on_icon
	GameSettings.setSFXVol(value)
	_changes_made = true
	
	
func _on_sfx_slider_value_changed(value: float) -> void:
	if value <= 0: 
		GameSettings.setSFXMuted(true)
		sfx_icon.texture = sfx_mute_icon
	else:
		GameSettings.setSFXMuted(false)
		sfx_icon.texture = sfx_full_icon
		
	GameSettings.setSFXVol(value)
	_changes_made = true
