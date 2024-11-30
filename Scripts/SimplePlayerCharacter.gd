extends Area2D

@export var ROTATE_SPEED = 5
@export var MOVE_SPEED = 1
var prevPos = []
var spritesToAdd = 0
@onready var sprite = preload("res://Assets/Dogs/OutlinedDog/BODY_SEGMENT_C.png")
@onready var pickupSpawner : PickupSpawner = get_tree().root.find_child("PickupSpawner", true, false)
@onready var butt : Sprite2D = $Butt

var segmentSprites : Array[Node2D]
var canAddSprites = true
var score : int = 0 

var frameDelay = 1
var segmentsPerSection = 50
var move = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Head.play("default")
	$Head/Legs.play("default")
	$Butt/Legs_back.play("default")
	$Butt/Tail.play("default")
	segmentSprites.push_back(butt)
	add_sprite()


func add_sprite():
	if(canAddSprites):
		spritesToAdd+=segmentsPerSection
		canAddSprites = false
		get_tree().create_timer(1.0).timeout.connect(resetSpriteTimer)


func resetSpriteTimer():
	canAddSprites = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if(!move): return
	
	prevPos.push_front([position, rotation])
	
	#Player has to move and rotate before the sprites so we don't override their global rotation by rotating the player. 
	move_local_y(delta*MOVE_SPEED)
#	position.x += delta*100
	
	if(Input.is_key_pressed(KEY_SPACE)):
		rotate(delta*ROTATE_SPEED)
	else:
		rotate(-delta*ROTATE_SPEED)
	
	
	if(spritesToAdd > 0):
		$Head/Legs.pause()
		var s : Sprite2D = Sprite2D.new()
		s.texture = sprite
		s.scale.y = 0.25
		segmentSprites.insert(segmentSprites.size()-1,s) #legger til nest sist.
		add_child(s)
		s.position =  Vector2(0,0)
		spritesToAdd-=1
	$Head/Legs.play()
	
	if(prevPos.size() > frameDelay * (segmentSprites.size())):
		var i : int = 0
		for s in segmentSprites:
			var newPos1 = prevPos[i*frameDelay]
			var nPos1 : Vector2 = newPos1[0]
			s.global_position = nPos1
			s.global_rotation = newPos1[1]
			i=i+1		


func _on_area_entered(area: Area2D) -> void:
	if(area.is_in_group("Treats")):
		score+=1
		for i : int in segmentsPerSection:
			add_sprite()
		pickupSpawner.SpawnPickup()         
		area.queue_free()
		print_debug("Score: " + var_to_str(score))
		
	elif(area.is_in_group("Dangers")):
		move = false
		var g : Control = get_tree().root.find_child("GameOverScreen",true, false)
		g.visible = true 
		queue_free()
