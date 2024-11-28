extends Control

@onready var scene = load("res://Scenes/PlayerDog.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_retry_button_button_down() -> void:
	#get_tree().root.find_child("World", true, false).queue_free()
	var s = scene.instantiate()
	get_tree().root.add_child(s)
	visible = false
	
	pass # Replace with function body.
