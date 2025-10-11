extends Node2D

@export var bubblePos : Vector2 = Vector2(-190, -40)
@export var skipEntireCutscene : bool = false

@onready var thoughtBubble = $ThoughtBubble_Sad
@onready var thoughtBubble1 = $ThoughtBubble_1
@onready var thoughtBubble2 = $ThoughtBubble_2
@onready var thoughtBubble3 = $ThoughtBubble_3

var bubblesSpawned : int = 0
var activeBubble : Node2D
var activeBubbleTween : Tween
var activeBubbleTimer : SceneTreeTimer
var levelSelect : bool = false

@onready var menu : PackedScene = preload("res://Scenes/main_menu.tscn")
@onready var world : Node2D = get_tree().root.find_child("World", true, false)

var skip : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	activeBubble = thoughtBubble
	thoughtBubble1.visible = false
	thoughtBubble2.visible = false
	thoughtBubble3.visible = false
	activeBubble.modulate.a = 0
	GameSettings.on_gameBegin.connect(queue_free)
	if(skipEntireCutscene):
		showMenu()
	else:
		activeBubble.visible = true
		var tween = get_tree().create_tween()
		activeBubbleTween = tween
		tween.tween_property(activeBubble, "modulate:a", 1, 0.3)
		tween.tween_callback(bubbleOut)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("Press")):
		if(activeBubbleTween != null 
		&& activeBubbleTween.is_valid() 
		&& activeBubbleTween.is_running()):
			activeBubbleTween.pause()
			activeBubbleTween.custom_step(1.0)
		else:
			if(activeBubbleTimer != null):
				activeBubbleTimer.time_left = 0
		skip = true
		
func bubbleOut():
	if(skip):
		deleteBubble()
	else:
		var timer = get_tree().create_timer(2.0)
		timer.timeout.connect(func():
			if(skip):
				activeBubble.modulate.a = 0
				deleteBubble()
			else:
				var tween = get_tree().create_tween()
				activeBubbleTween = tween
				tween.set_ease(Tween.EASE_IN)
				tween.tween_property(activeBubble, "modulate:a", 0, 0.3)
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
			showMenu()
#			queue_free()
			return	
	bubblesSpawned+=1
	activeBubble = bubble
#	bubble.global_position = bubblePos
	
	if(skip):
		skip = false
		
		activeBubble.modulate.a = 1
		bubbleOut()
	else:
		activeBubble.modulate.a = 0	
		activeBubble.visible = true
		var tween = get_tree().create_tween()
		activeBubbleTween = tween
		tween.tween_property(activeBubble, "modulate:a", 1, 0.3)
		tween.tween_callback(bubbleOut)


func showMenu():
	var mainMenu = menu.instantiate()
	get_tree().root.find_child("Gui",true, false).add_child(mainMenu)
	if levelSelect:
		mainMenu.openLevelSelect()
