extends Area2D

@export var ROTATE_SPEED = 5
@export var MOVE_SPEED = 1
var prevPos = []
var spritesToAdd = 0
@onready var sprite = preload("res://Assets/BODY_SEGMENT_C.png")

var segmentSprites : Array[Node2D]
@onready var butt : Sprite2D = $"../Butt"
var canAddSprites = true

var frameDelay = 1
var segmentsPerSection = 50
var move = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Head.play("default")
	$Head/Legs.play("default")
	$"../Butt/Legs_back".play("default")
	$"../Butt/Tail".play("default")
	segmentSprites.push_back(butt)
	for i : int in segmentsPerSection:
		var s : Sprite2D = Sprite2D.new()
		s.texture = sprite
		s.scale.y = 0.25
		#segmentSprites.push_back(s)
		segmentSprites.insert(segmentSprites.size()-1,s) #legger til nest sist.
		add_sibling.call_deferred(s)
		
	#butt.play("default")
	pass # Replace with function body.

func add_sprite():
	if(canAddSprites):
		spritesToAdd+=segmentsPerSection
		canAddSprites = false
		get_tree().create_timer(1.0).timeout.connect(resetSpriteTimer)
#	var s : Sprite2D = Sprite2D.new()
#	s.texture = sprite
#	s.scale.y = 0.25
#	segmentSprites.push_back(s)
#	segmentSprites.insert(segmentSprites.size()-1,s) #legger til nest sist.
#	add_sibling.call_deferred(s)

func resetSpriteTimer():
	canAddSprites = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if(!move): return
	
	if(spritesToAdd > 0):
		$Head/Legs.pause()
		var s : Sprite2D = Sprite2D.new()
		s.texture = sprite
		s.scale.y = 0.25
		segmentSprites.insert(segmentSprites.size()-1,s) #legger til nest sist.
		add_sibling(s)
		spritesToAdd-=1
	$Head/Legs.play()
	
	if(prevPos.size() > frameDelay * (segmentSprites.size())):
		var i : int = 0
		for s in segmentSprites:
			var newPos1 = prevPos[i*frameDelay]
			var nPos1 : Vector2 = newPos1[0]
			s.position = nPos1
			s.rotation = newPos1[1]
			i=i+1		
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
		for i : int in segmentsPerSection:
			add_sprite()
		area.queue_free()
	elif(area.is_in_group("Dangers")):
		move = false
	pass # Replace with function body.
