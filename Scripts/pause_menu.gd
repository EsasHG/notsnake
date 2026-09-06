extends Control
@onready var resume: AudioButton = $Panel/VBoxContainer/VBoxContainer/Resume

@onready var v_box_container: VBoxContainer = $Panel/VBoxContainer

const SETTINGS_SCREEN = preload("uid://b2gf7obd6wwhk")


func _ready() -> void:
	visibility_changed.connect(func():
		if visible: 
			resume.grab_focus(true))
	resume.grab_focus(true)
	UINavigator.open.call_deferred(v_box_container,false, false, _on_buttons_back)

#do we really want this here?
func _on_buttons_back() -> void:
	$Panel.visible = false
	UINavigator.back()


func _on_settings_pressed() -> void:
	UINavigator.open_from_scene(SETTINGS_SCREEN, true)
	pass # Replace with function body.


func _on_end_run_pressed() -> void:
	GameSettings.end_run()
	get_tree().paused = false
	queue_free()
