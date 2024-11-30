extends Control

@onready var scene = load("res://Scenes/PlayerDog.tscn")
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
		$RetryButton/TextureProgressBar.value += $RetryButton/TextureProgressBar.step
	else:
		$RetryButton/TextureProgressBar.value -= $RetryButton/TextureProgressBar.step
		
	if($RetryButton/TextureProgressBar.value == $RetryButton/TextureProgressBar.max_value):
		filled()
		
		
func filled():
	var s = scene.instantiate()
	get_tree().root.find_child("World", true, false).add_child(s)
	retryButtonPressed = false 
	visible = false
	$RetryButton/TextureProgressBar.value = 0
	

func _on_retry_button_button_down() -> void:
	retryButtonPressed = true
	#get_tree().root.find_child("World", true, false).queue_free()
	#var s = scene.instantiate()
	#get_tree().root.add_child(s)
	#visible = false
	
	pass # Replace with function body.


func _on_retry_button_button_up() -> void:
	retryButtonPressed = false
	
