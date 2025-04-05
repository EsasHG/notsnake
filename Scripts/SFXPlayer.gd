extends AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameSettings.on_sfx_volume_changed.connect(setVolume)
	setVolume(GameSettings.sfxVol)

func setVolume(new_vol : float):
	volume_db = new_vol
