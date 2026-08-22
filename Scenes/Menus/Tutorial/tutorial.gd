extends Control
@onready var popup_menu: PanelContainer = $OuterPanelContainer
@onready var next_button: Button = $OuterPanelContainer/VBoxContainer/HBoxContainer/NextButton
@onready var panel: Panel = $OuterPanelContainer/VBoxContainer/HBoxContainer/Panel
@onready var back_button: Button = $OuterPanelContainer/VBoxContainer/HBoxContainer/BackButton
@onready var description_label: Label = $OuterPanelContainer/VBoxContainer/DescriptionLabel


const PLAYER_SPAWN_NAME = "PlayerStart"
const SHOW_ARROW_MESSAGE = 5
var current_message: int  = 1
var _current_pickup_pos : Vector2
var _dragging = false
var prev_mouse_pos: Vector2 = Vector2.ZERO
var _banner_ad_dimension:Vector2 = Vector2.ZERO

func _ready() -> void:
	panel.visible = true
	back_button.visible = false
	description_label.text = tr("TUTORIAL_1")
	GameSettings.on_pickupSpawned.connect(_pickup_spawned)
	UINavigator.open.call_deferred(popup_menu,false,true)
	GameSettings.on_viewportChanged.connect(_on_viewport_changed)
	_on_viewport_changed()
	_current_pickup_pos = GameSettings.players[0].arrowTarget
	var player_spawner = get_tree().root.find_child(PLAYER_SPAWN_NAME,true,false)
	player_spawner.player_spawned.connect(_player_spawned)
	if GameSettings.adManager and GameSettings.adManager.banner_ad_showing:
		print("Ad dimension: ",GameSettings.adManager.admob.get_banner_dimension())
		_banner_ad_dimension = GameSettings.adManager.admob.get_banner_dimension_in_pixels()
		print("Ad dimension in pixels: ",GameSettings.adManager.admob.get_banner_dimension_in_pixels())
	
	
func _process(delta: float) -> void:
	if _dragging:
		var current_mouse_pos = get_global_mouse_position()
		var delta_mouse_pos = current_mouse_pos - prev_mouse_pos
		var popup_rect = popup_menu.get_rect()
		var new_pos = global_position+delta_mouse_pos
		if new_pos.x > (0-popup_rect.position.x) and new_pos.x < (get_viewport_rect().size.x - popup_rect.end.x):
			global_position.x += delta_mouse_pos.x
			
		if new_pos.y > (0-popup_rect.position.y) and new_pos.y < (get_viewport_rect().size.y - popup_rect.end.y - _banner_ad_dimension.y):
			global_position.y += delta_mouse_pos.y
			
		prev_mouse_pos = current_mouse_pos
		

func _player_spawned(player:PlayerDog) -> void:
	player.arrowTarget = _current_pickup_pos
	if current_message >= SHOW_ARROW_MESSAGE:
		await player.ready
		player.arrow.visible = true
		

func _on_viewport_changed() -> void:
	match GameSettings.viewport_mode:
		GameSettings.VIEWPORT_MODE.PORTRAIT:
			set_anchors_and_offsets_preset(PRESET_CENTER_TOP,Control.PRESET_MODE_KEEP_HEIGHT)
			position.y += 200
			pass
		GameSettings.VIEWPORT_MODE.LANDSCAPE:
			position = Vector2(1200.0,150) 
			set_anchors_and_offsets_preset(PRESET_TOP_RIGHT,Control.PRESET_MODE_KEEP_SIZE)
			position.y += 200
			position.x -= 340.0
			pass


func _on_next_button_pressed() -> void:
	back_button.visible = true
	if (current_message < 8):
		current_message+=1
		description_label.text = tr("TUTORIAL_" + str(current_message))
		match current_message:
			1:
				back_button.visible = false
				panel.visible = true
			2:
				back_button.visible = true
				panel.visible = false
			SHOW_ARROW_MESSAGE:
				next_button.visible = false
				GameSettings.players[0].arrow.visible = true
				GameSettings.on_pickup.connect(_on_next_button_pressed)
				panel.visible = true
			6:
				#UINavigator.force_back()
				panel.visible = false
				
				next_button.visible = true
				GameSettings.on_pickup.disconnect(_on_next_button_pressed)
			8:
				next_button.text = tr("CLOSE")
		#UINavigator.open(popup_menu,false,true)
	else:
		GameSettings.play_tutorial = false
		UINavigator.force_back()
		UINavigator.force_back()
		queue_free()


func _on_back_button_pressed() -> void:
	next_button.visible = true
	
	if (current_message > 1):
		current_message-=1
		description_label.text = tr("TUTORIAL_" + str(current_message))
		match current_message:
			1:
				panel.visible = true
				back_button.visible = false
			5:
				GameSettings.players[0].arrow.visible = true
				GameSettings.on_pickup.connect(_on_next_button_pressed)
			4:
				GameSettings.on_pickup.disconnect(_on_next_button_pressed)
				panel.visible = false
				next_button.visible = true
			7:
				next_button.text = tr("NEXT")


func _pickup_spawned(pickup : Area2D) -> void:
	_current_pickup_pos = pickup.global_position


func _on_outer_panel_container_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("Press"):
		prev_mouse_pos = get_global_mouse_position()
		print("Pressing!")
		_dragging = true
	elif event.is_action_released("Press"):
		_dragging = false
