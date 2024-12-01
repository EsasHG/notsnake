extends Control

var startButtonPressed = false
var startButtonStayFilled = false
@export var bubblePos : Vector2 = Vector2(-190, -40)

var thoughtBubble = preload("res://Scenes/ThoughtBubble_SadFace.tscn")
var thoughtBubble1 = preload("res://Scenes/ThoughtBubble_1.tscn")
var thoughtBubble2 = preload("res://Scenes/ThoughtBubble_2.tscn")
var thoughtBubble3 = preload("res://Scenes/ThoughtBubble_3.tscn")

@onready var world : Node2D = get_tree().root.find_child("World", true, false)

var bubblesSpawned : int = 0
var activeBubble : Node2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	$StartButton.grab_focus()
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($Panel, "modulate:a", 0, 2.0)
	
	#$StartButton.grab_focus()
	
	var music = get_tree().root.find_child("BGMusic", true, false)
	music.play()
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#$StartButton.grab_focus()
	
	if(startButtonPressed):
		$StartButton/TextureProgressBar.value += 100*delta
	elif(!startButtonStayFilled):
		$StartButton/TextureProgressBar.value -= 100*delta
		
	if(!startButtonStayFilled && $StartButton/TextureProgressBar.value == $StartButton/TextureProgressBar.max_value):
		filled()
		
func filled():
	startButtonStayFilled = true
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($StartButton, "position", Vector2(862,1126), 0.5)
	tween.tween_callback(menuOut)
	
	var tween2 = get_tree().create_tween()
	tween2.set_ease(Tween.EASE_IN)
	tween2.tween_property($Logo, "position",Vector2(1056, -500), 0.5)

	
func menuOut():
	$Logo.visible = false
	$StartButton.visible = false
	var bubble = thoughtBubble.instantiate()
	activeBubble = bubble
	bubble.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property(bubble, "modulate:a", 1, 0.3)
	tween.tween_callback(bubbleOut)
	bubble.global_position = bubblePos
	world.add_child(bubble)
	
func bubbleOut():
	var timer = get_tree().create_timer(2.0).timeout.connect(func():
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.tween_property(activeBubble, "modulate:a", 0, 0.3)
		tween.tween_callback(deleteBubble)
		)
	
	#var tween = get_tree().create_tween()
	#tween.set_ease(Tween.EASE_IN)
	#tween.tween_property(activeBubble, "modulate:a", 0, 2)
	#tween.tween_callback(deleteBubble)
	
	
	
func deleteBubble():
	print_debug("Deleting Bubble!")
	activeBubble.queue_free()
	var bubble
	match bubblesSpawned:
		0:
			bubble = thoughtBubble1.instantiate()
		1:
			bubble = thoughtBubble2.instantiate()
		2:
			bubble = thoughtBubble3.instantiate()
		_:
			var player = get_tree().root.find_child("PlayerDog", true, false)
			player.playerControl = true
			player.grabCamera()
			return
	bubblesSpawned+=1
	activeBubble = bubble
	activeBubble.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property(activeBubble, "modulate:a", 1, 0.3)
	tween.tween_callback(bubbleOut)
	bubble.global_position = bubblePos
	world.add_child(activeBubble)
	
	
func _on_start_button_button_down() -> void:
	print_debug("Start down!")
	startButtonPressed = true


func _on_start_button_button_up() -> void:
	print_debug("Start up!")
	startButtonPressed = false
pass # Replace with function body.
