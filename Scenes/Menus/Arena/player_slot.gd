class_name PlayerSlot
extends Control

@export var playerNr: int

@onready var head: AnimatedSprite2D = $Dog/Head
@onready var options_panel: PanelContainer = $OptionsPanel
@onready var arrows: Control = $Arrows
@onready var join_label: Label = $PanelContainer/JoinLabel
@onready var ready_label: Label = $PanelContainer/ReadyLabel
@onready var ready_button: Button = $OptionsPanel/Controls/Ready
@onready var hold_controls: CheckBox = $OptionsPanel/Controls/HoldControls
@onready var tap_controls: CheckBox = $OptionsPanel/Controls/TapControls

@onready var current_button : Button = ready_button

var dogColors: Array[Color] = GlobalInputMap.player_colors;
var hats: Array[Node]

enum BodyPart {Hat, Head}
var current_body_part :BodyPart = BodyPart.Head

var dog_selection_index = 0
var hat_selection_index = 0
var deviceID: int = -1;

var can_move_left = true
var can_move_right = true
var can_move_up = true
var can_move_down = true
var movement_r : float
var movement_l : float
var movement_u : float
var movement_d : float
var character_selected = false
var ready_pressed = false
var controls = true
var can_move_left_timer: Timer
var can_move_right_timer : Timer
func _ready() -> void:
		
	GlobalInputMap.ControllerIds = [-1, -1, -1, -1];
	can_move_left_timer = Timer.new()
	can_move_right_timer = Timer.new()
	add_child(can_move_left_timer)
	add_child(can_move_right_timer)

	ready_button.add_theme_stylebox_override("normal", ready_button.get_theme_stylebox("focus"))

	can_move_left_timer.timeout.connect(func(): can_move_left = true)
	can_move_right_timer.timeout.connect(func():can_move_right = true)
	head.frame = 1
	hats = $Dog/Head/Hats.get_children(true)
	
	reset()
	
func reset():
	deviceID = -1
	head.visible = false
	options_panel.visible = false
	arrows.visible = false
	join_label.visible = true
	ready_label.visible = false
	ready_button.set_pressed_no_signal(controls)

func setID(id: int):
	deviceID = id;
	head.visible = true
	options_panel.visible = false
	arrows.visible = true
	join_label.visible = false
	GlobalInputMap.ControllerIds[playerNr] = id;
	move_to_next_dog(0)
	

func _input(event: InputEvent) -> void:
	if event.device != deviceID:
		return
		
	if event.is_action_released("MenuCancel"):
		if ready_pressed:
			unpress_ready()
		elif character_selected:
			unselect_character()
		else:
			deviceID = -1;
			GlobalInputMap.ControllerIds[playerNr] = -1;
			reset()
	if event.is_action("Left") and not ready_pressed:
		movement_l = event.get_action_strength("Left")
	if event.is_action("Right") and not ready_pressed:
		movement_r = event.get_action_strength("Right")
	if event.is_action("Up") and not ready_pressed:
		movement_u = event.get_action_strength("Up")
	if event.is_action("Down") and not ready_pressed:
		movement_d = event.get_action_strength("Down")
	if event.is_action_released("MenuSelect"):
		if not character_selected:
			select_character()
		elif not ready_pressed:
			if current_button == ready_button:
				current_button.pressed.emit()
			elif current_button == hold_controls: 
				tap_controls.set_pressed_no_signal(false)
				hold_controls.set_pressed_no_signal(true)
				hold_controls.toggled.emit(true)
			else:
				hold_controls.set_pressed_no_signal(false)
				hold_controls.toggled.emit(false)
				tap_controls.set_pressed_no_signal(true)
				tap_controls.toggled.emit(true)
				
	
func _process(_delta: float) -> void:
	
	if not character_selected:
		if movement_l > 0.7 and can_move_left:
			can_move_left = false
			can_move_left_timer.start(0.5)
			if current_body_part == BodyPart.Hat:
				move_to_next_hat(-1)
			else:
				move_to_next_dog(-1)
			#AudioManager.play("UI/MoveCursor",0.04)
		if movement_r > 0.7 and can_move_right:
			can_move_right = false
			can_move_right_timer.start(0.5)

			if current_body_part == BodyPart.Hat:
				move_to_next_hat(1)
			else:
				move_to_next_dog(1)
		#AudioManager.play("UI/MoveCursor",0.04)
	if movement_u > 0.7 and can_move_up:
		can_move_up = false
		if not character_selected:
			switch_body_part()
		else:
			switch_selected_button()
			#AudioManager.play("UI/MoveCursor",0.04)
	if movement_d > 0.7 and can_move_down:
		can_move_down = false
		if not character_selected:
			switch_body_part()
		else:
			switch_selected_button()
			#AudioManager.play("UI/MoveCursor",0.04)
		
	can_move_left = movement_l < 0.7
	can_move_right = movement_r < 0.7
	can_move_up = movement_u < 0.7
	can_move_down = movement_d < 0.7

func move_to_next_dog(direction: int):
	dog_selection_index = wrap(dog_selection_index + direction, 0, dogColors.size())
	head.self_modulate = dogColors[dog_selection_index];
	$Dog/Head/Legs.self_modulate = dogColors[dog_selection_index];

func move_to_next_hat(direction: int):
	hats[hat_selection_index].visible = false
	hat_selection_index = wrap(hat_selection_index + direction, 0, hats.size())
	hats[hat_selection_index].visible = true
	

func ready_to_play():
	var rdy = (character_selected and ready_pressed) or deviceID == -1
	return rdy
	
func switch_body_part():
	Logging.logMessage("Switching body part!")
	current_body_part = BodyPart.Head if current_body_part != BodyPart.Head else BodyPart.Hat
	match current_body_part:
		BodyPart.Head:
			$AnimationPlayer.play_backwards("move_selection")
		_:
			$AnimationPlayer.play("move_selection")

func switch_selected_button() -> void:
	var next_button : Button;
	if movement_u > movement_d:
		next_button = current_button.find_valid_focus_neighbor(SIDE_TOP)
	else: 
		next_button = current_button.find_valid_focus_neighbor(SIDE_BOTTOM)

	if next_button:
		current_button.remove_theme_color_override("font_pressed_color")
		current_button.remove_theme_color_override("font_color")
		current_button.remove_theme_stylebox_override("normal")
		
		if next_button == ready_button:
			next_button.add_theme_stylebox_override("normal", next_button.get_theme_stylebox("focus"))
		else:
			next_button.add_theme_color_override("font_pressed_color", Color("eac750"))
			next_button.add_theme_color_override("font_color", Color("eac750"))
			
		current_button = next_button
		
		
func select_character():
	arrows.visible = false
	options_panel.visible = true
	
	GlobalInputMap.Player_Color_Selected[playerNr] = dog_selection_index
	GlobalInputMap.Player_Hats_Selected[playerNr] = hat_selection_index
	character_selected = true

func unselect_character():
	arrows.visible = true
	options_panel.visible = false
	GlobalInputMap.Player_Color_Selected.erase(playerNr)
	GlobalInputMap.Player_Hats_Selected.erase(playerNr)
	character_selected = false
	
	
func _on_ready_pressed() -> void:
	ready_pressed = true
	options_panel.visible = false;
	ready_label.visible = true;
	GlobalInputMap.Player_Controls_Selected[playerNr] = controls
	head.frame = 0
	
func unpress_ready() -> void:
	ready_pressed = false
	ready_label.visible = false
	options_panel.visible = true;
	GlobalInputMap.Player_Controls_Selected.erase(playerNr)
	head.frame = 1
	
func _on_hold_controls_toggled(toggled_on: bool) -> void:
	controls = toggled_on
