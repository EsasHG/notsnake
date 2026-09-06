extends Node2D

@export var bubblePos : Vector2 = Vector2(-190, -40)
@export var skipEntireCutscene : bool = false
@onready var direction_change_timer: Timer = $"Direction Change Timer"

@onready var thoughtBubble = $ThoughtBubble_Sad
@onready var thoughtBubble1 = $ThoughtBubble_1
@onready var thoughtBubble2 = $ThoughtBubble_2
@onready var thoughtBubble3 = $ThoughtBubble_3
@onready var bubble_dog: PlayerDog = $BubbleDog
@export var skip_button: AudioButton

var bubblesSpawned : int = 0
var activeBubble : Node2D
var activeBubbleTween : Tween
var activeBubbleTimer : Timer
var levelSelect : bool = false
var timers : Array[Timer]

@onready var world : Node2D = get_tree().root.find_child("World", true, false)
const ARENA_MENU = preload("uid://bo42loyctrla7")
const MAIN_MENU = preload("uid://jdiyiwxj7kh0")

var skip : bool = false
var move_dog:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bubble_dog.visible = false
	activeBubble = thoughtBubble
	thoughtBubble1.visible = false
	thoughtBubble2.visible = false
	thoughtBubble3.visible = false
	activeBubble.modulate.a = 0
	GameSettings.on_gameBegin.connect(queue_free)
	if(skipEntireCutscene):
		_on_skip_pressed()
	else:
		skip_button.pressed.connect(_on_skip_pressed)

func startBubbleCutscene():
	bubble_dog.visible = true
	if not skipEntireCutscene:
		activeBubbleTimer = _create_timer(1)
		activeBubbleTimer.timeout.connect(func():
			activeBubble.visible = true
			var tween = get_tree().create_tween()
			activeBubbleTween = tween
			tween.tween_property(activeBubble, "modulate:a", 1, 0.2)
			tween.tween_callback(bubbleOut)
		)
	else:
		_on_skip_pressed()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
	#if(Input.is_action_just_pressed("Press")):
		#if(activeBubbleTween != null 
		#&& activeBubbleTween.is_valid() 
		#&& activeBubbleTween.is_running()):
			#activeBubbleTween.pause()
			#activeBubbleTween.custom_step(1.0)
		#else:
			#if(activeBubbleTimer != null):
				#activeBubbleTimer.time_left = 0
		#skip = true


func change_direction() -> void:
	if move_dog:
		bubble_dog.rotateRight = !bubble_dog.rotateRight
		bubble_dog.playerControl = true
	

func bubbleOut():
	if(skip):
		deleteBubble()
	else:
		var timer = _create_timer(1.4)
		timer.timeout.connect(func():
			if(skip):
				activeBubble.modulate.a = 0
				deleteBubble()
			else:
				var tween = get_tree().create_tween()
				activeBubbleTween = tween
				tween.set_ease(Tween.EASE_IN)
				tween.tween_property(activeBubble, "modulate:a", 0, 0.2)
				tween.tween_callback(deleteBubble)
			)
		activeBubbleTimer = timer
	
	#var tween = get_tree().create_tween()
	#tween.set_ease(Tween.EASE_IN)
	#tween.tween_property(activeBubble, "modulate:a", 0, 2)
	#tween.tween_callback(deleteBubble)
	

func deleteBubble():
	activeBubble.queue_free()
	var bubble
	match bubblesSpawned:
		0:
			bubble = thoughtBubble1
		1:
			bubble = thoughtBubble2
		2:
			bubble = thoughtBubble3
		_:
			move_dog = true
			var timer = _create_timer(3.0)
			timer.timeout.connect(showMenu)
			return	
	bubblesSpawned+=1
	activeBubble = bubble
#	bubble.global_position = bubblePos
	
	activeBubble.modulate.a = 0	
	activeBubble.visible = true
	await _create_timer(0.5).timeout
	var tween = get_tree().create_tween()
	activeBubbleTween = tween
	tween.tween_property(activeBubble, "modulate:a", 1, 0.2)
	tween.tween_callback(bubbleOut)


func showMenu():
	if skip_button:
		skip_button.visible = false
	var mainMenu = null
	if GameSettings.game_mode == GameSettings.GAME_MODE.SINGLE_PLAYER:
		mainMenu = UINavigator.open_from_scene(MAIN_MENU,false,true)
		#queue_free()
		#mainMenu = MAIN_MENU.instantiate()
	else:
		mainMenu = UINavigator.open_from_scene(ARENA_MENU,false)
		$MapTutorial1.reparent(mainMenu)
		$BubbleCamera.reparent(mainMenu)
		#mainMenu = ARENA_MENU.instantiate()
		
	#UINavigator.open(mainMenu, false)
	if levelSelect:
		mainMenu.open_level_select()


func _create_timer(wait_time :float) -> Timer:
	var t = Timer.new()
	timers.append(t)
	t.wait_time = wait_time
	t.autostart = true
	
	t.timeout.connect(func(): 
		timers.erase(t)
		t.queue_free(),CONNECT_DEFERRED)
	add_child(t)
	return t


func _on_skip_pressed() -> void:
	skip = true
	if is_instance_valid(activeBubbleTween):
		activeBubbleTween.stop()
	for t in timers:
		if is_instance_valid(t) and !t.is_stopped():
			t.stop()
			t.queue_free()
	for i in range(2,get_child_count()):
		get_child(i).queue_free()
		
	showMenu()
	pass # Replace with function body.
