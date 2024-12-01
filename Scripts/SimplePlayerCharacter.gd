extends Area2D

class_name PlayerDog

@export var ROTATE_SPEED = 5
@export var MOVE_SPEED = 1
var prevPositionsArr = []

var spritesToAdd = 0
var timer : float = 0.0
var spawnTime : float = 0.02
@onready var prevPos : Vector2 = position
var prevLeft : Vector2 = Vector2(1,0)
var prevDir : int = -1
@onready var sprite = preload("res://Assets/Dogs/OutlinedDog/BODY_SEGMENT_C.png")
@onready var segment = preload("res://Scenes/DogSegment.tscn")
@onready var pickupSpawner : PickupSpawner = get_tree().root.find_child("PickupSpawner", true, false)
@onready var segmentParent : Node2D = Node2D.new()
@onready var hindLegs = find_child("Legs_back", true, false)
var segmentSprites : Array[Node2D]
var canAddSprites = true
var score : int = 0 
var showFps = false
@onready var butt = $Butt

var playerControl = false
var frameDelay = 1
var segmentsPerSection =40
var move = true
signal GameOver
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Head.play("default")
	$Head/Legs.play("default")
	$Butt/ButtSprite/Legs_back.play("default")
	$Butt/ButtSprite/Tail.play("default")
	#segmentSprites.push_back($Butt)
	add_sprite()
	get_tree().create_timer(1.0).timeout.connect(func(): butt.get_child(0).disabled = false)
	
	add_sibling.call_deferred(segmentParent)
	butt.reparent(segmentParent)
	
func add_sprite():
	if(canAddSprites):
		spritesToAdd+=segmentsPerSection
		canAddSprites = false
		get_tree().create_timer(0.1).timeout.connect(resetSpriteTimer)
		
			#if(spritesToAdd > 0):
		hindLegs.pause()
#		$Head/Legs.pause()
		#for i:int in segmentsPerSection: 
			#var s : Sprite2D = Sprite2D.new()
			#s.texture = sprite
			#s.scale.y = 0.5
			#segmentSprites.insert(segmentSprites.size()-1,s) #legger til nest sist.
			#add_child(s)
			#s.position =  $Butt.position
			#spritesToAdd-=1

func add_segment():
	if(canAddSprites):
		spritesToAdd+=segmentsPerSection
		canAddSprites = false
		get_tree().create_timer(0.1).timeout.connect(resetSpriteTimer)
		
			#if(spritesToAdd > 0):
		#$Head/Legs.pause()
		hindLegs.pause()
		
		#for i:int in segmentsPerSection: 
			#var s  = segment.instantiate()
			#segmentSprites.insert(segmentSprites.size()-1,s) #legger til nest sist.
			#add_child.call_deferred(s)
			#s.position =  $Butt.position
			#spritesToAdd-=1
		#$Head/Legs.play()


func resetSpriteTimer():
	canAddSprites = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(!move): return
#	position.x += delta*100
		
	var dir : int = -1
	if(Input.is_action_pressed("Press") && playerControl):
		dir = 1
		rotate(delta*ROTATE_SPEED)
	else:
		dir = -1
		rotate(-delta*ROTATE_SPEED)
		
	#Player has to move and rotate before the sprites so we don't override their global rotation by rotating the player. 
	move_local_y(delta*MOVE_SPEED)
	
	var pos = global_position
	var left = transform.x*dir
	
	prevLeft = prevLeft * dir * prevDir
	var ang = left.angle_to(prevLeft)
	var dist = left.project(pos-prevPos).distance_to(prevPos-pos)/sin(ang)*dir
	var distVec = pos-prevPos
	var proj = distVec.project(left)
	var dist_to = proj.distance_to(prevPos-pos)
	var si = sin(ang)
	var end = dist_to/si
	
	var rotationCenter = pos+(left*dist) 
	timer+=delta
	while timer > spawnTime:
		timer-=spawnTime
		var s 
		
		if(spritesToAdd > 0):
			s = segment.instantiate()
			segmentParent.add_child.call_deferred(s)
			spritesToAdd-=1
			
		else:
			s = segmentSprites.pop_back()
			s.get_child(0).disabled = true
			if(!hindLegs.is_playing()):
				hindLegs.play()
			
		#	$Head/Legs.play()
		if(segmentSprites.size() > 10):
			segmentSprites[10].get_child(0).disabled = false
			
		var t = timer/delta
		var newPos = rotationCenter - left.rotated(ang*t)*dist
		var newRot = transform.x.rotated(ang*t)
		
		s.global_position = newPos
		s.global_rotation = newRot.angle()
		
		segmentSprites.push_front(s)
		
		butt.global_position = segmentSprites.back().global_position
		butt.global_rotation = segmentSprites.back().global_rotation
	#while timer > spawntime: 
		#spawn
		#remove spawntime
		#funksjon for å predicte hvor jeg ville vært på substep	
		#prev frame pos/rot, current frame pos/rot, middle of rotation
	
	
	prevPositionsArr.push_front([global_position, rotation])
	
	if(Input.is_key_pressed(KEY_F)):
		showFps = true
		var fps : float = 1/ delta
		$"../../CanvasLayer/Gui/FPS_Tracker".text = "Framerate: " + var_to_str(fps)
	else:
		showFps = false
#		$"../../CanvasLayer/Gui/FPS_Tracker".text = ""
		
	
	 
	#var i : int = 0
	#for s in segmentSprites:
		#var newPos1 
		#var nPos1 : Vector2
#
		#if(prevPositionsArr.size() > i):	
			#newPos1 = prevPositionsArr[i]
			#nPos1 = newPos1[0]
		#else:
			#newPos1 = prevPositionsArr[prevPositionsArr.size()-2] #if there's more sprites than we know where to put, use the second to last position
			#nPos1 = newPos1[0]
		#s.global_position = nPos1
		#s.global_rotation = newPos1[1]
		#i+=1		
	#if(prevPositionsArr.size() > (segmentSprites.size())*frameDelay):
		#prevPositionsArr.pop_back()
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
	prevPos = global_position
	prevLeft = left
	prevDir = dir
	queue_redraw()

func _on_area_entered(area: Area2D) -> void:
	
	if(area == butt):
		if(playerControl == false):
			return	
		GameOver.emit()
		move = false
		var g : Control = get_tree().root.find_child("VictoryScreen",true, false)
		g.SetScore(score)
		g.visible = true 
		var camera = get_tree().root.find_child("Camera2D", true, false)
		camera.reparent(get_tree().root.find_child("World", true, false))
		playerControl = false
		segmentParent.queue_free()
		queue_free()
		
	elif(area.is_in_group("Dangers")):
		
		GameOver.emit()
		var music = get_tree().root.find_child("BGMusic", true, false)
		music.stop()
		var m :  AudioStreamPlayer = music
		m.autoplay = false
		m.stream_paused = true
		m.stop()
		m.stream = load("res://Assets/Sound/zapsplat_cartoon_musical_orchestral_pizzicato_riff_ending_fail_92164.mp3")
		m.play()
		if(playerControl == false):
			return	
		move = false
		var g : Control = get_tree().root.find_child("GameOverScreen",true, false)
		g.SetScore(score)
		g.visible = true 
		var camera = get_tree().root.find_child("Camera2D", true, false)
		camera.reparent(get_tree().root.find_child("World", true, false))
		playerControl = false
		segmentParent.queue_free()
		queue_free()
	elif(area.is_in_group("Treats")):
		
		$Head/BarkSound.pitch_scale = randf_range(0.9,1.1)
		$Head/BarkSound.play()
		
		if(canAddSprites):
			score+=1
			for i : int in segmentsPerSection:
				add_segment()
			pickupSpawner.SpawnPickup()
			area.queue_free()
			print_debug("Score: " + var_to_str(score))

		
func grabCamera():	
	var camera = get_tree().root.find_child("Camera2D", true, false)
	camera.reparent(self)
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "position", Vector2(0,0), 0.5)
	tween.tween_callback(func(): playerControl = true)
	#camera.position = Vector2(0,0)
#	playerControl = true
