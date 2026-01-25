extends Area2D

class_name PlayerDog

@export var ROTATE_SPEED = 5
@export var MOVE_SPEED = 1
@export var OVERALL_SPEED = 0.9
@export var MIN_ARROW_DIST = 120
@export var MAX_ARROW_DIST = 150
@export var hats : Array[Node]
@export var playerControl = false
@export var iframes_time : float = 0.3

@onready var prevPos : Vector2 = position
@onready var sprite = preload("res://Assets/Dogs/OutlinedDog/BODY_SEGMENT_C.png")
@onready var segment = preload("uid://b64vm8vof02aj")
@onready var pickupSpawner : PickupSpawner = get_tree().root.find_child("PickupSpawner", true, false)
@onready var segmentParent : Node2D = Node2D.new()
@onready var hindLegs = find_child("Legs_back", true, false)
@onready var butt = $Butt
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var iframes_timer : Timer

var prevPositionsArr = []
var playerID = -1
var currentHat = -1
var spritesToAdd = 0
var timer : float = 0.0
var spawnTime : float = 0.02
var prevLeft : Vector2 = Vector2(1,0)
var prevDir : int = -1
var holdControls = true
var _invulnerable = true 
var score = 0
var grabbed_tail : bool = false
var segmentSprites : Array[Node2D]
var canAddSprites = true

var segmentsPerSection = 20
var move = true
var rotateRight = false
var arrowTarget : Vector2

	
func _ready() -> void:
	Logging.logMessage("Player ready!")
	
	_invulnerable = true
	iframes_timer = Timer.new()	
	iframes_timer.autostart = true
	iframes_timer.one_shot = true
	iframes_timer.timeout.connect(func(): _invulnerable = false)
	add_child(iframes_timer)
	
	$Head.play("default")
	$Head/Legs.play("default")
	$Butt/ButtSprite/Legs_back.play("default")
	$Butt/ButtSprite/Tail.play("default")
	add_sprite()
	get_tree().create_timer(1.0).timeout.connect(func(): butt.get_child(0).disabled = false)

	add_sibling.call_deferred(segmentParent)
	butt.reparent(segmentParent)
	$Head.self_modulate = self_modulate
	$Head/Legs.modulate = self_modulate
	segmentParent.modulate = self_modulate
	$Head/BarkSound.volume_db = GameSettings.sfxVol
	Input.emulate_mouse_from_touch = true
	hats = $Head/Hats.get_children(true)
	for hat in hats:
		hat.visible = false
		
	if currentHat <0 || currentHat > hats.size()-1:
		currentHat = 0
		
	hats[currentHat].visible = true
	GameSettings.on_pickupSpawned.connect(set_arrow_target)
	GameSettings.on_controls_changed.connect(_on_controls_changed)
	GameSettings.on_gameBegin.connect(func(): $Head/ArrowHolder.visible = true)
	visibility_changed.connect(func(): segmentParent.visible =visible) 
	
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

func _input(event: InputEvent) -> void:
	if event.device != GlobalInputMap.ControllerIds[playerID]:
		return
	if holdControls:
		if(event.is_action("Press")):
			if(event.is_pressed()):
				rotateRight = true
			else:
				rotateRight = false
	else: 
		if(event.is_action("Press") and event.is_pressed()):
			rotateRight = !rotateRight
			
	if event.is_action("Pause"):
		GameSettings._on_pause_pressed()
			
func _process(delta: float) -> void:
	if(!move): return
	var dir : int = -1
	
	if(rotateRight && playerControl):
		dir = 1
		rotate(delta*ROTATE_SPEED*OVERALL_SPEED)
	else:
		dir = -1
		rotate(-delta*ROTATE_SPEED*OVERALL_SPEED)
		
	#Player has to move and rotate before the sprites so we don't override their global rotation by rotating the player. 
	move_local_y(delta*MOVE_SPEED*OVERALL_SPEED)
	
	var pos = position
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
			s.visible = true
			s.get_child(0).disabled = true ##child 0 is collision shape
			if(!hindLegs.is_playing()):
				hindLegs.play()
			
		#why this??
		if(segmentSprites.size() > 10):
			segmentSprites[10].get_child(0).disabled = false
			
		var t = timer/delta
		var newPos = rotationCenter - left.rotated(ang*t)*dist
		var newRot = transform.x.rotated(ang*t)
		
		s.position = newPos
		s.rotation = newRot.angle()
		
		segmentSprites.push_front(s)
		
		butt.position = segmentSprites.back().position
		butt.rotation = segmentSprites.back().rotation
		segmentSprites.back().visible = false
		segmentSprites[segmentSprites.size()-2].visible = true
	prevPositionsArr.push_front([position, rotation])
	
	prevPos = position
	prevLeft = left
	prevDir = dir

	$Head/ArrowHolder.look_at(arrowTarget)
	$Head/ArrowHolder.rotate(deg_to_rad(-90))
	var arrowDist = position.distance_to(arrowTarget)
	var lerped = (arrowDist-MIN_ARROW_DIST)/MAX_ARROW_DIST
	$Head/ArrowHolder/Arrow.modulate.a = lerped

func _on_area_entered(area: Area2D) -> void:
	if(_invulnerable or playerControl == false or not GameSettings.game_running):
		return
		
	if(area == butt):
		Logging.logMessage("Player won!")
		grabbed_tail = true
		move = false
		playerControl = false
		GameSettings.player_lost(self)
		segmentParent.queue_free()
		GameSettings.unlock_achievement("Wi(e)nner")
		queue_free()
		
	elif(area.is_in_group("Dangers")):
		Logging.logMessage("Player Lost!")
		GameSettings.player_lost(self)
		if area.is_in_group("DogSegment"):
			Logging.logMessage("Collided with self!")
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
			score+=1
			if GlobalInputMap.Player_Score.keys().has(playerID):
				GlobalInputMap.Player_Score[playerID]+=1
			else:
				GlobalInputMap.Player_Score[playerID] = 1
			area.queue_free()
			
	elif(area.is_in_group("Present")):
		if(canAddSprites):
			var hatRand : int = currentHat
			while hatRand == currentHat:
				hatRand = randi_range(0, hats.size()-1)
			if(currentHat != -1):
				hats[currentHat].visible = false
			hats[hatRand].visible = true
			currentHat = hatRand
			bark()
			GameSettings.unlock_achievement("Dapper dog")
			for i : int in segmentsPerSection:
				add_segment()
			GameSettings.on_pickup.emit()
			area.queue_free()
			
			
func bark():
	$Head/BarkSound.pitch_scale = randf_range(0.9,1.1)
	$Head/BarkSound.play()
	
func set_arrow_target(target:Node2D):
	arrowTarget = target.global_position
	
func _on_controls_changed(_holdControls:bool):
	rotateRight = false
