extends Area2D

@export var ROTATE_SPEED = 5
@export var MOVE_SPEED = 1
var prevPos = []

@onready var sprite =  preload("res://Assets/BODY_SEGMENT.png")

@export var segmentSprites : Array[Sprite2D]
@onready var butt : Sprite2D = $"../Butt"

var frameDelay = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Head.play("default")
	$Head/Legs.play("default")
	$"../Butt/Tail".play("default")
	for i : int in 5:
		add_sprite()
		
	#butt.play("default")
	pass # Replace with function body.

func add_sprite():
	var s : Sprite2D = Sprite2D.new()
	s.texture = sprite
	s.scale.y = 0.25
	add_sibling.call_deferred(s)
	segmentSprites.push_back(s)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if(prevPos.size() > frameDelay * (segmentSprites.size())):
		var i : int = 0
		for s in segmentSprites:
			var newPos1 = prevPos[i*frameDelay]
			var nPos1 : Vector2 = newPos1[0]
			s.position = nPos1
			s.rotation = newPos1[1]
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


func _on_area_entered(area: Area2D) -> void:
	if(area.is_in_group("Treats")):
		print_debug("Adding sprritesa")
		for i : int in 20:
			add_sprite()
	
	pass # Replace with function body.
