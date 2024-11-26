extends Area2D

@export var ROTATE_SPEED = 5
@export var MOVE_SPEED = 1
var prevPos = []

@export var segmentSprites : Array[Sprite2D]
@onready var butt : AnimatedSprite2D = $"../Butt"

var frameDelay = 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("default")
	butt.play("default")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if(prevPos.size() > frameDelay * (segmentSprites.size()-1)):
		var i : int = 0
		for s in segmentSprites:
			var newPos = prevPos[i*frameDelay]
			var nPos : Vector2 = newPos[0]
			s.position = nPos
			s.rotation = newPos[1]
			i=i+1
		var newPos = prevPos.pop_back()
		var nPos : Vector2 = newPos[0]
		butt.position = nPos
		butt.rotation = newPos[1]
		
		
	
		#var newPos : Array[Vector2, int] = prevPos.pop_back()
		#var nPos : Vector2 = newPos[0]
		#$Sprite2D.global_position = nPos
		#$Sprite2D.global_rotation = newPos[1]
	
	prevPos.push_front([position, rotation])
	move_local_y(delta*MOVE_SPEED)
#	position.x += delta*100
	
	if(Input.is_key_pressed(KEY_SPACE)):
		rotate(delta*ROTATE_SPEED)
	else:
		rotate(-delta*ROTATE_SPEED)
	pass
