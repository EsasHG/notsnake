extends Control

var startButtonPressed = false
var quitButtonPressed = false
var startButtonStayFilled = false
var justPressed = false
var justPressedTime = 0.2
var start_focused = preload("res://Assets/UI/startbutton_5.png")
var quit_unfocused = preload("res://Assets/UI/QUIT_3.png")

@onready var playGamesSignInClient : PlayGamesSignInClient = %PlayGamesSignInClient
@onready var leaderboardsClient : PlayGamesLeaderboardsClient = %PlayGamesLeaderboardsClient
@onready var levelSelect = preload("res://Scenes/LevelSelect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if not GodotPlayGameServices.android_plugin:
		printerr("Could not find Google Play Games Services plugin!")
	if(playGamesSignInClient):
		playGamesSignInClient.user_authenticated.connect(_on_user_authenticated)	
		playGamesSignInClient.is_authenticated()
	
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

func _on_start_button_pressed() -> void:
	print_debug("Start pressed!")
	var l = levelSelect.instantiate()
	get_parent().add_child(l)
	queue_free()
