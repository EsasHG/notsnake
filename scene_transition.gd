extends Control

class_name  SceneTransition
@onready var panel: Panel = $Panel
@onready var start_x: float = panel.position.x

var transitionTime: float = 0.6

signal transition_in_finished
signal transition_out_finished
func _ready() -> void:
	transition_in()
	
	
func transition_in() -> void:
	var tween:Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(panel, "position", Vector2(0,0), transitionTime)
	tween.tween_callback(_transition_in_finished)

func _transition_in_finished():
	transition_in_finished.emit()

func transition_out() -> void:
	var tween:Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "position", Vector2(-start_x,0), transitionTime) #TODO: something fancy to find a better end point?
	tween.tween_callback(_transition_out_finished)

func _transition_out_finished() -> void:
	transition_out_finished.emit()
	queue_free()
