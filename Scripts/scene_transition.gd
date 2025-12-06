extends Control

class_name  SceneTransition
@onready var panel: Panel = $Panel
@onready var start_x: float = panel.position.x
@onready var dog_control: Control = $Panel/Control
@onready var dog: PlayerDog = $Panel/Control/BubbleDog

@export var skip_transition_in:bool = false
var transitionTime: float = 0.1

signal transition_in_finished
signal transition_out_finished
func _ready() -> void:
	Logging.logMessage("Scene transition ready")
	dog.visible = false
	dog.collision_shape_2d.disabled = true
	#dog_control.modulate.a = 0
	
	get_tree().create_timer(0.55).timeout.connect(func(): 
		dog.visible = true
		#dog_control.modulate.a = 0
		#var t : Tween = get_tree().create_tween()
		#t.tween_property(dog_control, "modulate:a",1,0.5)
		)
		

	if skip_transition_in:
		Logging.logMessage("Skipping transition in!")
		
		panel.position = Vector2(0,0)
		panel.modulate.a = 1
	else:
		transition_in()
	
func _process(_delta: float) -> void:
	pass#dog.rotateRight = ! dog.rotateRight
	
	
func transition_in() -> void:
	Logging.logMessage("transitioning in!")
	
	panel.position = Vector2(0,0)
	panel.modulate.a = 0
	var tween:Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
#	tween.tween_property(panel, "position", Vector2(0,0), transitionTime)
	tween.tween_property(panel, "modulate:a", 1, transitionTime)
	tween.tween_callback(_transition_in_finished)

func _transition_in_finished():
	transition_in_finished.emit()

func transition_out() -> void:
	Logging.logMessage("transitioning out!")
	var tween:Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate:a", 0, transitionTime) #TODO: something fancy to find a better end point?
	#tween.tween_property(panel, "position", Vector2(-start_x,0), transitionTime) #TODO: something fancy to find a better end point?
	tween.tween_callback(_transition_out_finished)

func _transition_out_finished() -> void:
	transition_out_finished.emit()
	queue_free()
