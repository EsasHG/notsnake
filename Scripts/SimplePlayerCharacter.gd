extends Area2D

class_name PlayerDog

@export var ROTATE_SPEED = 5
@export var MOVE_SPEED = 1
var prevPos = []
var spritesToAdd = 0
@onready var sprite = preload("res://Assets/Dogs/OutlinedDog/BODY_SEGMENT_C.png")
@onready var segment = preload("res://Scenes/DogSegment.tscn")
@onready var pickupSpawner : PickupSpawner = get_tree().root.find_child("PickupSpawner", true, false)

var segmentSprites : Array[Node2D]
var canAddSprites = true
var score : int = 0 
var showFps = false

var playerControl = false
var frameDelay = 1
var segmentsPerSection = 50
var move = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Head.play("default")
	$Head/Legs.play("default")
	$Butt/ButtSprite/Legs_back.play("default")
	$Butt/ButtSprite/Tail.play("default")
	segmentSprites.push_back($Butt)
	add_sprite()
	get_tree().create_timer(1.0).timeout.connect(func(): $Butt/CollisionShape2D.disabled = false)
	

func add_sprite():
	if(canAddSprites):
		spritesToAdd+=segmentsPerSection
		canAddSprites = false
		get_tree().create_timer(1.0).timeout.connect(resetSpriteTimer)
		
			#if(spritesToAdd > 0):
		$Head/Legs.pause()
		for i:int in segmentsPerSection: 
			var s : Sprite2D = Sprite2D.new()
			s.texture = sprite
			s.scale.y = 0.25
			segmentSprites.insert(segmentSprites.size()-1,s) #legger til nest sist.
			add_child(s)
			s.position =  $Butt.position
			spritesToAdd-=1
		$Head/Legs.play()

func add_segment():
	if(canAddSprites):
		spritesToAdd+=segmentsPerSection
		canAddSprites = false
		get_tree().create_timer(1.0).timeout.connect(resetSpriteTimer)
		
			#if(spritesToAdd > 0):
		$Head/Legs.pause()
		for i:int in segmentsPerSection: 
			var s  = segment.instantiate()
			segmentSprites.insert(segmentSprites.size()-1,s) #legger til nest sist.
			add_child.call_deferred(s)
			s.position =  $Butt.position
			spritesToAdd-=1
		$Head/Legs.play()


func resetSpriteTimer():
	canAddSprites = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(!move): return
	
	prevPos.push_front([position, rotation])
	
	#Player has to move and rotate before the sprites so we don't override their global rotation by rotating the player. 
	move_local_y(delta*MOVE_SPEED)
#	position.x += delta*100
	if(playerControl):
		if(Input.is_action_just_pressed("Press")):
			$Head/BarkSound.play()
		if(Input.is_action_just_released("Press")):
			$Head/BarkSound.play()
		
	
	if(Input.is_action_pressed("Press") && playerControl):
			rotate(delta*ROTATE_SPEED)
	else:
		rotate(-delta*ROTATE_SPEED)
		
		
	if(Input.is_key_pressed(KEY_F)):
		showFps = true
		var fps : float = 1/ delta
		$"../../CanvasLayer/Gui/FPS_Tracker".text = "Framerate: " + var_to_str(fps)
	else:
		showFps = false
		$"../../CanvasLayer/Gui/FPS_Tracker".text = ""
		
	
	 
	var i : int = 0
	for s in segmentSprites:
		var newPos1 
		var nPos1 : Vector2

		if(prevPos.size() > i * frameDelay):	
			newPos1 = prevPos[i*frameDelay]
			nPos1 = newPos1[0]
		else:
			newPos1 = prevPos[prevPos.size()-2] #if there's more sprites than we know where to put, use the second to last position
			nPos1 = newPos1[0]
		s.global_position = nPos1
		s.global_rotation = newPos1[1]
		i+=1		
	if(prevPos.size() > (segmentSprites.size())*frameDelay):
		prevPos.pop_back()
	#if(spritesToAdd > 0):
		#$Head/Legs.pause()
		#var s : Sprite2D = Sprite2D.new()
		#s.texture = sprite
		#s.scale.y = 0.25
		#segmentSprites.insert(segmentSprites.size()-1,s) #legger til nest sist.
		#add_child(s)
		#s.position =  Vector2(0,0)
		#spritesToAdd-=1
	#$Head/Legs.play()
	


func _on_area_entered(area: Area2D) -> void:
	
	if(area == $Butt):
		print_debug("You Won!")
		move = false
		var g : Control = get_tree().root.find_child("VictoryScreen",true, false)
		g.SetScore(score)
		g.visible = true 
		var camera = get_tree().root.find_child("Camera2D", true, false)
		camera.reparent(get_tree().root.find_child("World", true, false))
		queue_free()
	elif(area.is_in_group("Treats")):
		if(canAddSprites):
			score+=1
			for i : int in segmentsPerSection:
				add_segment()
			pickupSpawner.SpawnPickup()
			area.queue_free()
			print_debug("Score: " + var_to_str(score))
		
	elif(area.is_in_group("Dangers")):
		move = false
		var g : Control = get_tree().root.find_child("GameOverScreen",true, false)
		g.SetScore(score)
		g.visible = true 
		var camera = get_tree().root.find_child("Camera2D", true, false)
		camera.reparent(get_tree().root.find_child("World", true, false))
		queue_free()
		
func grabCamera():	
	var camera = get_tree().root.find_child("Camera2D", true, false)
	camera.reparent(self, false)
	camera.position = Vector2(0,0)
	playerControl = true
