extends Area2D

class_name PlayerDog

@export var ROTATE_SPEED = 5
@export var MOVE_SPEED = 1
@export var OVERALL_SPEED = 0.9
@export var MIN_ARROW_DIST = 120
@export var MAX_ARROW_DIST = 150

var prevPositionsArr = []
@export var hats : Array[Node]

var currentHat = -1
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
var showFps = false
@onready var butt = $Butt

@export var playerControl = false
var frameDelay = 1
var segmentsPerSection = 20
var move = true
var rotateRight = false
var arrowTarget : Vector2

func _ready() -> void:
	$Head.play("default")
	$Head/Legs.play("default")
	$Butt/ButtSprite/Legs_back.play("default")
	$Butt/ButtSprite/Tail.play("default")
	add_sprite()
	get_tree().create_timer(1.0).timeout.connect(func(): butt.get_child(0).disabled = false)
	
	add_sibling.call_deferred(segmentParent)
	butt.reparent(segmentParent)
	GameSettings.currentScore = 0
	$Head/BarkSound.volume_db = GameSettings.sfxVol
	Input.emulate_mouse_from_touch = true
	hats = $Head/Hats.get_children(true)
	
	GameSettings.on_pickupSpawned.connect(SetArrowTarget)
	GameSettings.on_gameBegin.connect(func(): $Head/ArrowHolder.visible = true)
#	if(playerControl):
#		get_tree().create_timer(1.0).timeout.connect(func(): GameSettings.on_gameBegin.emit())
func add_sprite():
	if(canAddSprites):
		spritesToAdd+=segmentsPerSection
		canAddSprites = false
		get_tree().create_timer(0.1).timeout.connect(resetSpriteTimer)
		hindLegs.pause()

func add_segment():
	if(canAddSprites):
		spritesToAdd+=segmentsPerSection
		canAddSprites = false
		get_tree().create_timer(0.1).timeout.connect(resetSpriteTimer)
		hindLegs.pause()

func resetSpriteTimer():
	canAddSprites = true

func _unhandled_input(event: InputEvent) -> void:
	#event.is_action_pressed()
	if(event.is_action("Press")):
		if(event.is_pressed()):
			rotateRight = true
		else:
			rotateRight = false
			
func _process(delta: float) -> void:
	
	if(!move): return
#	position.x += delta*100
	var dir : int = -1
	
	if(rotateRight && playerControl):
		dir = 1
		rotate(delta*ROTATE_SPEED*OVERALL_SPEED)
	else:
		dir = -1
		rotate(-delta*ROTATE_SPEED*OVERALL_SPEED)
		
	#Player has to move and rotate before the sprites so we don't override their global rotation by rotating the player. 
	move_local_y(delta*MOVE_SPEED*OVERALL_SPEED)
	
	var pos = global_position
	var left = transform.x*dir
	
	prevLeft = prevLeft * dir * prevDir
	var ang = left.angle_to(prevLeft)
	var dist = left.project(pos-prevPos).distance_to(prevPos-pos)/sin(ang)*dir

	
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
	
	#if(Input.is_key_pressed(KEY_F)):
		#showFps = true
		#var fps : float = 1/ delta
		#$"../../CanvasLayer/Gui/FPS_Tracker".text = "Framerate: " + var_to_str(fps)
	#else:
		#showFps = false
#		$"../../CanvasLayer/Gui/FPS_Tracker".text = ""
		
	prevPos = global_position
	prevLeft = left
	prevDir = dir

	$Head/ArrowHolder.look_at(arrowTarget)
	$Head/ArrowHolder.rotate(deg_to_rad(-90))
	var arrowDist = position.distance_to(arrowTarget)
	var lerped = (arrowDist-MIN_ARROW_DIST)/MAX_ARROW_DIST
	$Head/ArrowHolder/Arrow.modulate.a = lerped

func _on_area_entered(area: Area2D) -> void:
	if(area == butt):
		print_debug("Player Won!")
		GameSettings.on_gameOver.emit(true)
		
		if(playerControl == false):
			return	
		move = false
		var camera = get_tree().root.find_child("Camera2D", true, false)
		camera.reparent(get_tree().root.find_child("World", true, false))
		playerControl = false
		segmentParent.queue_free()
		queue_free()
		
	elif(area.is_in_group("Dangers")):
		print_debug("Player Lost!")
		if(playerControl == false):
			printerr("Player overlapped danger while not having control!")
			return	
	
		GameSettings.on_gameOver.emit(false)

		move = false
		playerControl = false
		segmentParent.queue_free()
		queue_free()
		
	elif(area.is_in_group("Treats")):
		if(canAddSprites):
			bark()
			
			for i : int in segmentsPerSection:
				add_segment()
			GameSettings.on_pickup.emit()
			
			area.queue_free()
			print_debug("Currrent Score: " + var_to_str(GameSettings.currentScore))
			
	elif(area.is_in_group("Present")):
		if(canAddSprites):
		
			print_debug("Currrent Score: " + var_to_str(GameSettings.currentScore))
			var hatRand : int = currentHat
			while hatRand == currentHat:
				hatRand = randi_range(0, hats.size()-1)
			
			if(currentHat != -1):
				hats[currentHat].visible = false
		
			hats[hatRand].visible = true
			currentHat = hatRand
			
			bark()
			for i : int in segmentsPerSection:
				add_segment()
			GameSettings.on_pickup.emit()
			area.queue_free()
			print_debug("Currrent Score: " + var_to_str(GameSettings.currentScore))
			
func grabCamera():	
	var camera = get_tree().root.find_child("Camera2D", true, false)
	camera.reparent(self)
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "position", Vector2(0,0), 0.5)
	tween.tween_callback(func(): playerControl = true)
	
	#playerControl = true
	
func bark():
	$Head/BarkSound.pitch_scale = randf_range(0.9,1.1)
	$Head/BarkSound.play()
	
func SetArrowTarget(target:Node2D):
	arrowTarget = target.global_position
	
