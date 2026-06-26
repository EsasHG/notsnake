extends Area2D

class_name PlayerDog
@export var ROTATE_SPEED = 5
@export var MOVE_SPEED = 1
@export var OVERALL_SPEED = 0.9
@export var MIN_ARROW_DIST = 120
@export var MAX_ARROW_DIST = 150
@export var playerControl = false
@export var iframes_time : float = 0.3

@onready var prevPos : Vector2 = position
const DOG_SEGMENT = preload("uid://b64vm8vof02aj")

@onready var pickupSpawner : PickupSpawner = get_tree().root.find_child("PickupSpawner", true, false)
@onready var segmentParent : Node2D = Node2D.new()
@onready var head: AnimatedSprite2D = $Head
@onready var legs: AnimatedSprite2D = $Head/Legs
@onready var hindLegs: AnimatedSprite2D = $Butt/ButtSprite/Legs_back
@onready var butt_sprite: Sprite2D = $Butt/ButtSprite
@onready var tail: AnimatedSprite2D = $Butt/ButtSprite/Tail
@onready var hat: Sprite2D = $Head/Hat
@onready var butt = $Butt
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var arrow: Sprite2D = $Head/ArrowHolder/Arrow

var iframes_timer : Timer

var prevPositionsArr = []
var playerID = -1
var spritesToAdd = 0
var timer : float = 0.0
var spawnTime : float = 0.02
var prevLeft : Vector2 = Vector2(1,0)
var prevDir : int = -1
var _invulnerable = true 
var score = 0
var grabbed_tail : bool = false
var segments : Array[Node2D]
var canAddSprites = true
var segment_sprite : Texture2D

var segmentsPerSection = 20
var move = true
var rotateRight = false
var arrowTarget : Vector2


func _ready() -> void:
	Logging.logMessage("Player ready!")
	
	_invulnerable = true
	iframes_timer = Timer.new()
	iframes_timer.name = "IFramesTimer"
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
	
	if GameSettings.game_mode == GameSettings.GAME_MODE.SINGLE_PLAYER:
		set_skin(GlobalInputMap.skins_selected[0])
		set_hat(GlobalInputMap.hats_selected[0])
	Input.emulate_mouse_from_touch = true
	
	GameSettings.on_pickupSpawned.connect(set_arrow_target)
	GameSettings.on_controls_changed.connect(_on_controls_changed)
	if not GameSettings.play_tutorial:
		GameSettings.on_gameBegin.connect(func(): arrow.visible = true)
	GameSettings.on_dogHatChanged.connect(set_hat)
	GameSettings.on_dogSkinChanged.connect(set_skin)
	visibility_changed.connect(func(): segmentParent.visible =visible) 
	arrow.visible = false

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
	if playerID == -1:
		return
	
	if GameSettings.game_mode != GameSettings.GAME_MODE.SINGLE_PLAYER:
		if event.device != GlobalInputMap.ControllerIds[playerID]:
			return
	if GlobalInputMap.Player_Controls_Selected[playerID]:
		if(event.is_action("Press")):
			if(event.is_pressed()):
				rotateRight = true
			else:
				rotateRight = false
	else: 
		if(event.is_action("Press") and event.is_pressed()):
			rotateRight = !rotateRight
			
	if event.is_action("Pause"):
		GameSettings.pause_game()


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
			s = DOG_SEGMENT.instantiate()
			s.get_child(1).texture = segment_sprite
			segmentParent.add_child.call_deferred(s)
			spritesToAdd-=1
			
		else:
			s = segments.pop_back()
			s.visible = true
			s.get_child(0).disabled = true ##child 0 is collision shape
			if(!hindLegs.is_playing()):
				hindLegs.play()
			
		#why this??
		if(segments.size() > 10):
			segments[10].get_child(0).disabled = false
			
		var t = timer/delta
		var newPos = rotationCenter - left.rotated(ang*t)*dist
		var newRot = transform.x.rotated(ang*t)
		
		s.position = newPos
		s.rotation = newRot.angle()
		
		segments.push_front(s)
		
		butt.position = segments.back().position
		butt.rotation = segments.back().rotation
		segments.back().visible = false
		segments[segments.size()-2].visible = true
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
		if not GlobalInputMap.hats["COWBOY"].unlocked:
			GameSettings.on_somethingUnlocked.emit("COWBOY")
			GlobalInputMap.hats["COWBOY"].unlocked = true
			SaveManager.save_game()
			AchievementManager.unlock_achievement("Wi(e)nner")	##TODO: Fix so this gets unlocked if player logs in later.
			
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
			

func bark():
	$Head/BarkSound.pitch_scale = randf_range(0.9,1.1)
	$Head/BarkSound.play()


func set_arrow_target(target:Node2D):
	arrowTarget = target.global_position


func set_skin(skin_id:String) -> void:
	if not GlobalInputMap.skins.has(skin_id):
		Logging.error("Trying to use skin '" + skin_id +"', but could not find it in the list of skins." )
		skin_id = "DEFAULT"
	var skin:DogSkin = GlobalInputMap.skins[skin_id]
	self_modulate = skin.modulate
	head.sprite_frames = skin.head
	head.self_modulate = self_modulate
	legs.sprite_frames = skin.legs_front
	legs.modulate = skin.modulate
	hindLegs.sprite_frames = skin.legs_back
	butt_sprite.texture = skin.butt
	tail.sprite_frames = skin.tail
	legs.play("default")
	hindLegs.play("default")
	tail.play("default")
	segment_sprite = skin.body_segment
	segmentParent.modulate = skin.modulate
	hat.position = GlobalInputMap.hats[GlobalInputMap.hats_selected[0]].offset + skin.hat_offset
	
	for seg in segments:
		seg.get_child(1,true).texture = segment_sprite

func set_hat(hat_id:String):
	var new_hat =  GlobalInputMap.hats[hat_id]

	hat.texture = new_hat.texture
	hat.position = new_hat.offset + GlobalInputMap.skins[GlobalInputMap.skins_selected[0]].hat_offset

#why is this here
func _on_controls_changed(_hold_controls:bool):
	rotateRight = false 
