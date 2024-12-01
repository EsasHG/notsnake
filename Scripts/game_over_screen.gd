extends Control

var score : int
@onready var scene = load("res://Scenes/PlayerDog.tscn")

@onready var BGmusic = get_tree().root.find_child("BGMusic", true, false)
var retryButtonPressed =false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visibility_changed.connect(on_visibility_changed)


func on_visibility_changed():
	if(visible):
		$RetryButton.grab_focus()
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if(retryButtonPressed):
		$RetryButton/TextureProgressBar.value += 100*delta
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
	
	
func SetScore(in_score : int):
	score = in_score
	
	var str_score : String = var_to_str(score)
	for c in str_score:
		var tex : TextureRect = TextureRect.new()
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.texture = load("res://Assets/UI/Font pngs/nr_" + c +".png")
		$HBoxContainer.add_child(tex)
	
func _on_retry_button_button_down() -> void:
	retryButtonPressed = true
	#get_tree().root.find_child("World", true, false).queue_free()
	#var s = scene.instantiate()
	#get_tree().root.add_child(s)
	#visible = false
	
	pass # Replace with function body.


func _on_retry_button_button_up() -> void:
	retryButtonPressed = false
	
