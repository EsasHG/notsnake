extends VBoxContainer
var _changes_made : bool = true
@onready var easy: AudioButton = $DiffucultyButtons/Easy
@onready var normal: AudioButton = $DiffucultyButtons/Normal
@onready var hard: AudioButton = $DiffucultyButtons/Hard
@onready var insane: AudioButton = $DiffucultyButtons/Insane
@onready var difficulty_explanation: Label = $DifficultyExplanation


func _ready() -> void:
	match GameSettings.difficulty:
		GameSettings.DIFFICULTY.EASY:
			easy.set_pressed_no_signal(true)
		GameSettings.DIFFICULTY.NORMAL:
			normal.set_pressed_no_signal(true)
		GameSettings.DIFFICULTY.HARD:
			hard.set_pressed_no_signal(true)
		GameSettings.DIFFICULTY.INSANE:
			insane.set_pressed_no_signal(true)
	

func _on_hold_controls_toggled(toggled_on: bool) -> void:
	GameSettings.setControls(toggled_on)
	_changes_made = true


func _on_slow_pressed() -> void:
	GameSettings.set_difficulty(GameSettings.DIFFICULTY.EASY)


func _on_normal_pressed() -> void:
	GameSettings.set_difficulty(GameSettings.DIFFICULTY.NORMAL)


func _on_fast_pressed() -> void:
	GameSettings.set_difficulty(GameSettings.DIFFICULTY.HARD)


func _on_insane_pressed() -> void:
	GameSettings.set_difficulty(GameSettings.DIFFICULTY.INSANE)
