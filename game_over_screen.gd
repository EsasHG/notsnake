extends Control

@onready var scene = preload("res://SceneAgain.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_retry_button_button_down() -> void:
	var s = scene.instantiate()
	get_tree().root.add_child(s)
	queue_free()
	
	pass # Replace with function body.
