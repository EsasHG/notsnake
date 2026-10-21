extends VBoxContainer
var _changes_made : bool = true

func _ready() -> void:
	pass
	

func _on_hold_controls_toggled(toggled_on: bool) -> void:
	GameSettings.setControls(toggled_on)
	_changes_made = true
