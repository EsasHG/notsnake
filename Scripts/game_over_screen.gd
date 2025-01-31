extends Control

var retryButtonPressed = false
var quitButtonPressed = false
var justPressed = false
var justPressedTime = 0.2
var retry_unfocused = preload("res://Assets/UI/RETRY_2.png")
var retry_focused = preload("res://Assets/UI/RETRY_5.png")

var quit_unfocused = preload("res://Assets/UI/QUIT_3.png")
var quit_focused = preload("res://Assets/UI/QUIT_1.png")
var score : int
@onready var scene = load("res://Scenes/PlayerDog.tscn")

@onready var BGmusic = get_tree().root.find_child("BGMusic", true, false)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visibility_changed.connect(on_visibility_changed)
	if(!OS.has_feature("web") && !OS.has_feature("mobile")):
		if(visible):
			$RetryButton.grab_focus()


func on_visibility_changed():
	
	if(!OS.has_feature("web") && !OS.has_feature("mobile")):
		if(visible):
			$RetryButton.grab_focus()
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(!OS.has_feature("web") && !OS.has_feature("mobile")):
		if(quitButtonPressed):
			$QuitButton/TextureProgressBar.value += 80*delta
		elif(!quitButtonPressed):
			$QuitButton/TextureProgressBar.value -= 100*delta
			
		if($QuitButton/TextureProgressBar.value == $QuitButton/TextureProgressBar.max_value):
			quitFilled()
	
		if(retryButtonPressed):
			$RetryButton/TextureProgressBar.value += 80*delta
		else:
			$RetryButton/TextureProgressBar.value -= 100*delta
			
		if($RetryButton/TextureProgressBar.value == $RetryButton/TextureProgressBar.max_value):
			filled()
		
		
func filled():    
	var s : PlayerDog = scene.instantiate()
	get_tree().root.find_child("World", true, false).add_child(s)
	s.grabCamera()
	retryButtonPressed = false 
	visible = false
	$RetryButton/TextureProgressBar.value = 0
	
	for c in $HBoxContainer.get_children():
		if(c.name != "ScoreLabel"):
			c.queue_free()
	
	var loseMusic = get_tree().root.find_child("LoseMusic", true, false)
	loseMusic.stop()
	BGmusic.play()
	
func quitFilled():
	get_tree().quit()
	
	
func SetScore(in_score : int):
	score = in_score
	
	var str_score : String = var_to_str(score)
	for c in str_score:
		var tex : TextureRect = TextureRect.new()
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.texture = load("res://Assets/UI/Font pngs/nr_" + c +".png")
		$HBoxContainer.add_child(tex)
	
func _on_retry_button_button_down() -> void:
	if(!OS.has_feature("web") && !OS.has_feature("mobile")):
		justPressed = true
		get_tree().create_timer(justPressedTime).timeout.connect(func(): justPressed = false)
	elif OS.has_feature("mobile"):
		filled()
	retryButtonPressed = true
	#get_tree().root.find_child("World", true, false).queue_free()
	#var s = scene.instantiate()
	#get_tree().root.add_child(s)
	#visible = false
	
	pass # Replace with function body.


func _on_retry_button_button_up() -> void:
	
	if(!OS.has_feature("web") && !OS.has_feature("mobile")):
		if(justPressed):
			$QuitButton.grab_focus()
			justPressed = false
		
			$RetryButton/TextureProgressBar.texture_under = retry_unfocused
			$QuitButton/TextureProgressBar.texture_under = quit_focused
	retryButtonPressed = false


func _on_quit_button_button_down() -> void:
	quitButtonPressed = true
	justPressed = true
	get_tree().create_timer(justPressedTime).timeout.connect(func(): justPressed = false)


func _on_quit_button_button_up() -> void:	
	if(justPressed):
		$RetryButton.grab_focus()
		$RetryButton/TextureProgressBar.texture_under = retry_focused
		$QuitButton/TextureProgressBar.texture_under = quit_unfocused
		justPressed = false
	quitButtonPressed = false
	pass # Replace with function body.
