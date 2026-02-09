extends PathFollow2D

@export var speed : float = 10.0 
func _process(delta: float) -> void:
	progress += delta * speed
