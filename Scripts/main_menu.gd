extends Control

var startButtonPressed = false
var quitButtonPressed = false
var startButtonStayFilled = false
var justPressed = false
var justPressedTime = 0.2
var start_focused = preload("res://Assets/UI/startbutton_5.png")
var quit_unfocused = preload("res://Assets/UI/QUIT_3.png")

@onready var levelSelect = preload("res://Scenes/LevelSelect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if not GodotPlayGameServices.android_plugin:
		printerr("Could not find Google Play Games Services plugin!")
		_on_user_authenticated(false)
	if(GameSettings.signInClient):
		GameSettings.signInClient.user_authenticated.connect(_on_user_authenticated)	
		GameSettings.signInClient.is_authenticated()
	
	visible = true
	#$Panel2.visible = true
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
		$HBoxContainer/StartButton.grab_focus()
	
	var music = get_tree().root.find_child("BGMusic", true, false)
	if(music):
		music.play()
	
	
func filled():
	startButtonStayFilled = true
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($HBoxContainer/StartButton, "position", Vector2($HBoxContainer/StartButton.position.x,1126), 0.5)
	tween.tween_callback(menuOut)
	
	var signInTween = get_tree().create_tween()
	signInTween.set_ease(Tween.EASE_IN)
	signInTween.tween_property($"HBoxContainer/Sign In", "position", Vector2($"HBoxContainer/Sign In".position.x,1126), 0.5)
	
	var leaderboardTween = get_tree().create_tween()
	leaderboardTween.set_ease(Tween.EASE_IN)
	leaderboardTween.tween_property($HBoxContainer/Leaderboard,"position", Vector2($HBoxContainer/Leaderboard.position.x,1126), 0.5)
	
	var tween2 = get_tree().create_tween()
	tween2.set_ease(Tween.EASE_IN)
	tween2.tween_property($Logo, "position",Vector2(1056, -500), 0.5)
	
	
func quitFilled():
	get_tree().quit()
	pass
			 
func menuOut():
	$Logo.visible = false
	$HBoxContainer/StartButton.visible = false
	$HBoxContainer/QuitButton.visible = false

	
	
func _on_quit_button_button_down() -> void:
	quitButtonPressed = true
	justPressed = true
	get_tree().create_timer(justPressedTime).timeout.connect(func(): justPressed = false)


func _on_quit_button_button_up() -> void:
	if(justPressed):
		$HBoxContainer/StartButton.grab_focus()
		$HBoxContainer/StartButton/TextureProgressBar.texture_under = start_focused
		
		justPressed = false
	quitButtonPressed = false
	pass # Replace with function body.


func _on_user_authenticated(is_authenticated: bool) -> void:
	if is_authenticated:
		$"HBoxContainer/Sign In".visible = false
		$HBoxContainer/Leaderboard.visible = true
		print_debug("Authenticated!")
	else:
		$"HBoxContainer/Sign In".visible = true
		$HBoxContainer/Leaderboard.visible = false
		print_debug("Not authenticated!")
		

func _on_sign_in_pressed() -> void:
	GameSettings.signInClient.sign_in()
	pass # Replace with function body.


func _on_leaderboard_pressed() -> void:
	GameSettings.leaderboardsClient.show_all_leaderboards()

func _on_start_button_pressed() -> void:
	print_debug("Start pressed!")
	var l = levelSelect.instantiate()
	get_parent().add_child(l)
	queue_free()
