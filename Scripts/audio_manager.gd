extends Node
@onready var bg_music: AudioStreamPlayer = $BGMusic
#var pitch_shift : AudioEffectPitchShift
# Called when the node enters the scene tree for the first time.


func _ready() -> void:
	GameSettings.on_gameOver.connect(stopMusic)
	GameSettings.on_gamePaused.connect(pause_music)
	GameSettings.on_gameUnpaused.connect(unpause_music)
	#pitch_shift = AudioEffectPitchShift.new()
	#pitch_shift.fft_size = AudioEffectPitchShift.FFT_SIZE_MAX
	#AudioServer.add_bus_effect(AudioServer.get_bus_index("Music"), pitch_shift)
	
	
func stopMusic():
	if !bg_music:
		bg_music = find_child("BGMusic", true, false)
	
	bg_music.stop()
	bg_music.stream_paused = true
	bg_music.pitch_scale = 1
	var loseMusic = find_child("LoseMusic", true, false)
	loseMusic.play()

func pause_music(): 
	var t = get_tree().create_tween()
	t.set_ease(Tween.EASE_IN)
	t.set_pause_mode(Tween.TweenPauseMode.TWEEN_PAUSE_PROCESS)
	t.set_ignore_time_scale(true)
	t.tween_property(bg_music, "pitch_scale", 0.1, 1)
	t.tween_callback(func(): bg_music.stream_paused = true)
	
	
func unpause_music():
	var t = get_tree().create_tween()
	t.set_ease(Tween.EASE_IN_OUT)
	t.set_ignore_time_scale(true)
	bg_music.stream_paused = false
	t.tween_property(bg_music, "pitch_scale", 1, 1)
