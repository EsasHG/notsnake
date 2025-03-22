extends Control

var startButtonPressed = false
var quitButtonPressed = false
var startButtonStayFilled = false
var justPressed = false
var justPressedTime = 0.2
var start_unfocused = preload("res://Assets/UI/startbutton_2.png")
var start_focused = preload("res://Assets/UI/startbutton_5.png")
var quit_unfocused = preload("res://Assets/UI/QUIT_3.png")
var quit_focused = preload("res://Assets/UI/QUIT_1.png")
@export var bubblePos : Vector2 = Vector2(-190, -40)

var thoughtBubble = preload("res://Scenes/ThoughtBubble_SadFace.tscn")
var thoughtBubble1 = preload("res://Scenes/ThoughtBubble_1.tscn")
var thoughtBubble2 = preload("res://Scenes/ThoughtBubble_2.tscn")
var thoughtBubble3 = preload("res://Scenes/ThoughtBubble_3.tscn")

@onready var playGamesSignInClient : PlayGamesSignInClient = %PlayGamesSignInClient
@onready var leaderboardsClient : PlayGamesLeaderboardsClient = %PlayGamesLeaderboardsClient
@onready var world : Node2D = get_tree().root.find_child("World", true, false)

var bubblesSpawned : int = 0
var activeBubble : Node2D
var activeBubbleTween : Tween
var activeBubbleTimer : SceneTreeTimer
var skip : bool = false

func _enter_tree() -> void:
	print_debug("Entered tree!")
	GodotPlayGameServices.initialize()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if not GodotPlayGameServices.android_plugin:
		printerr("Could not find Google Play Games Services plugin!")
		
	playGamesSignInClient.is_authenticated()
	visible = true
	$Panel.modulate.a = 0
	get_tree().create_timer(0.5).timeout.connect(func():	
		var blackPanelTween = get_tree().create_tween()
		blackPanelTween.set_ease(Tween.EASE_IN)
		blackPanelTween.tween_property($Panel2, "modulate:a", 0, 1.5)
		)
	
	#var comicStartTimer = get_tree().create_timer(0.5).timeout.connect(func():
		#
		#var comicFadeInTween = get_tree().create_tween()
		#comicFadeInTween.set_ease(Tween.EASE_IN)
		#comicFadeInTween.tween_property($Panel, "modulate:a", 1, 1.0)
		#comicFadeInTween.tween_callback(func():
			#var timer = get_tree().create_timer(4.0).timeout.connect(func(): 
				#var tween = get_tree().create_tween()
				#tween.set_ease(Tween.EASE_OUT)
				#tween.tween_property($Panel, "modulate:a", 0, 1.0)
				#tween.tween_callback(func(): 
					#$StartButton.grab_focus()
					#var blackPanelTween = get_tree().create_tween()
					#blackPanelTween.set_ease(Tween.EASE_IN)
					#blackPanelTween.tween_property($Panel2, "modulate:a", 0, 1.5)
				#)
			#)
		#)
	#)
	if(!OS.has_feature("web") && !OS.has_feature("mobile")):
		$StartButton.grab_focus()
	
	var music = get_tree().root.find_child("BGMusic", true, false)
	music.play()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#$StartButton.grab_focus()
	if(!OS.has_feature("web") && !OS.has_feature("mobile")):
		if(quitButtonPressed):
			$QuitButton/TextureProgressBar.value += 80*delta
		elif(!quitButtonPressed):
			$QuitButton/TextureProgressBar.value -= 100*delta
			
		if($QuitButton/TextureProgressBar.value == $QuitButton/TextureProgressBar.max_value):
			quitFilled()
	
		if(startButtonPressed):
			$StartButton/TextureProgressBar.value += 80*delta
		elif(!startButtonStayFilled):
			$StartButton/TextureProgressBar.value -= 100*delta
		
	if(!startButtonStayFilled && $StartButton/TextureProgressBar.value == $StartButton/TextureProgressBar.max_value):
		filled()
		
	if(startButtonStayFilled && Input.is_action_just_pressed("Press")):
		if( activeBubbleTween != null && activeBubbleTween.is_valid() && activeBubbleTween.is_running()):
			activeBubbleTween.pause()
			activeBubbleTween.custom_step(1.0)
		else:
			if(activeBubbleTimer != null):
				activeBubbleTimer.time_left = 0
		skip = true
		
		
func filled():
	startButtonStayFilled = true
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($StartButton, "position", Vector2($StartButton.position.x,1126), 0.5)
	tween.tween_callback(menuOut)
	
	var quitButtonTween = get_tree().create_tween()
	quitButtonTween.set_ease(Tween.EASE_IN)
	quitButtonTween.tween_property($QuitButton, "position", Vector2($QuitButton.position.x,1126), 0.5)
	
	var signInTween = get_tree().create_tween()
	signInTween.set_ease(Tween.EASE_IN)
	signInTween.tween_property($"Sign In", "position", Vector2($"Sign In".position.x,1126), 0.5)
	
	var leaderboardTween = get_tree().create_tween()
	leaderboardTween.set_ease(Tween.EASE_IN)
	leaderboardTween.tween_property($Leaderboard,"position", Vector2($Leaderboard.position.x,1126), 0.5)
	
	var tween2 = get_tree().create_tween()
	tween2.set_ease(Tween.EASE_IN)
	tween2.tween_property($Logo, "position",Vector2(1056, -500), 0.5)
	
	
func quitFilled():
	get_tree().quit()
	pass
			 
func menuOut():
	$Logo.visible = false
	$StartButton.visible = false
	$QuitButton.visible = false
	var bubble = thoughtBubble.instantiate()
	activeBubble = bubble
	bubble.modulate.a = 0
	var tween = get_tree().create_tween()
	activeBubbleTween = tween
	tween.tween_property(bubble, "modulate:a", 1, 0.3)
	tween.tween_callback(bubbleOut)
	bubble.global_position = bubblePos
	world.add_child(bubble)
	
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
			visible = false
			SignalManager.on_gameBegin.emit()
			return
	bubblesSpawned+=1
	activeBubble = bubble
	bubble.global_position = bubblePos
	world.add_child(activeBubble)
	
	if(skip):
		skip = false
		
		activeBubble.modulate.a = 1
		bubbleOut()
	else:
		activeBubble.modulate.a = 0
		var tween = get_tree().create_tween()
		activeBubbleTween = tween
		tween.tween_property(activeBubble, "modulate:a", 1, 0.3)
		tween.tween_callback(bubbleOut)
	
	
func _on_start_button_button_down() -> void:
	print_debug("Start down!")
	if(!OS.has_feature("web") && !OS.has_feature("mobile")):

		justPressed = true
		get_tree().create_timer(justPressedTime).timeout.connect(func(): justPressed = false)
	elif OS.has_feature("mobile"):
		filled()
	startButtonPressed = true


func _on_start_button_button_up() -> void:
	print_debug("Start up!")
	if(!OS.has_feature("web") && !OS.has_feature("mobile")):
		if(justPressed):
			$QuitButton.grab_focus()
			justPressed = false
			
			$StartButton/TextureProgressBar.texture_under = start_unfocused
			$QuitButton/TextureProgressBar.texture_under = quit_focused
	
	startButtonPressed = false
pass # Replace with function body.


func _on_quit_button_button_down() -> void:
	quitButtonPressed = true
	justPressed = true
	get_tree().create_timer(justPressedTime).timeout.connect(func(): justPressed = false)


func _on_quit_button_button_up() -> void:
	if(justPressed):
		$StartButton.grab_focus()
		$StartButton/TextureProgressBar.texture_under = start_focused
		$QuitButton/TextureProgressBar.texture_under = quit_unfocused
		justPressed = false
	quitButtonPressed = false
	pass # Replace with function body.


func _on_user_authenticated(is_authenticated: bool) -> void:
	if is_authenticated:
		$"Sign In".visible = false
		$Leaderboard.visible = true
		print_debug("Authenticated!")
	else:
		$"Sign In".visible = true
		$Leaderboard.visible = false
		print_debug("Not authenticated!")
		

func _on_sign_in_pressed() -> void:
	playGamesSignInClient.sign_in()
	pass # Replace with function body.


func _on_leaderboard_pressed() -> void:
	leaderboardsClient.show_all_leaderboards()
