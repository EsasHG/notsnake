extends Area2D

@export var SPEED = 600
@export var TARGET_X : int = -829

var dir : int  = -1
var start
var move = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start = position

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if(!move):
		return
	position.x += dir*delta*SPEED
	if(position.x <= TARGET_X):
		dir=1
		move = false
		get_tree().create_timer(0.5).timeout.connect(flip.bind(true))
	elif(position.x >= start.x):
		get_tree().create_timer(0.5).timeout.connect(flip.bind(false))
		move = false
		dir=-1
		
func flip(flip:bool):
	$Sprite2D.flip_h = flip
	get_tree().create_timer(0.5).timeout.connect(func(): move = true)
	
