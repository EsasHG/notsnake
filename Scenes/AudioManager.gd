extends Node

var musicMuted : bool = false
var sfxMuted : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setMusicVol(GameSettings.musicVol)
	setSFXVol(GameSettings.sfxVol)
	
	if db_to_linear(GameSettings.musicVol) == 0:
		musicMuted = true
		
	if db_to_linear(GameSettings.sfxVol) == 0:
		sfxMuted = true
		
	$"../CanvasLayer/Gui/AudioButtons/VBoxContainer/MusicMute".set_pressed_no_signal(musicMuted)
	$"../CanvasLayer/Gui/AudioButtons/VBoxContainer/SFXMute".set_pressed_no_signal(sfxMuted)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_toggled(toggled_on: bool) -> void:
	musicMuted = toggled_on
	var vol : int = -15
	if musicMuted: 
		vol = linear_to_db(0)
	GameSettings.setMusicVol(vol)
	setMusicVol(vol)

		



func _on_sfx_mute_toggled(toggled_on: bool) -> void:
	sfxMuted = toggled_on
	var vol : int = -15
	if sfxMuted: 
		vol = linear_to_db(0)
	GameSettings.setSFXVol(vol)
	setSFXVol(vol)

func setSFXVol(in_vol : int):
	for audio : AudioStreamPlayer2D in get_tree().root.find_children("*", "AudioStreamPlayer2D", true, false):
		audio.volume_db = in_vol

func setMusicVol(in_vol : int):
	for audio : AudioStreamPlayer in get_tree().root.find_children("*", "AudioStreamPlayer", true, false):
		audio.volume_db = in_vol
