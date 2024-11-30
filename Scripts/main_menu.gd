extends Control

var startButtonPressed = false
var startButtonStayFilled = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$StartButton.grab_focus()
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
	var player = get_tree().root.find_child("PlayerDog", true, false)
	player.playerControl = true
	player.grabCamera()
	
	$StartButton.visible = false
	$Logo.visible = false
	
func _on_start_button_button_down() -> void:
	print_debug("Start down!")
	startButtonPressed = true


func _on_start_button_button_up() -> void:
	print_debug("Start up!")
	
	startButtonPressed = false
pass # Replace with function body.
