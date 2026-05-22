extends Control
@onready var main_screen_container: PanelContainer = $AdLayoutContainer/MainScreen
@onready var color_picker_button: ColorPickerButton = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/VBoxContainer/HBoxContainer/ColorPickerButton
@onready var text_edit: TextEdit = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/VBoxContainer/HexEdit/TextEdit
@onready var _head: AnimatedSprite2D = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/VBoxContainer/Control/Control/Head
@onready var _legs: AnimatedSprite2D = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/VBoxContainer/Control/Control/Head/Legs
@onready var _hat: Sprite2D = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/VBoxContainer/Control/Control/Head/Hat

@onready var hat_select_screen: PanelContainer = $AdLayoutContainer/HatSelectContainer
@onready var hat_buttons: HFlowContainer = $AdLayoutContainer/HatSelectContainer/ScrollContainer/InnerContainer/VBoxContainer/HatButtons
@onready var skin_select_screen: PanelContainer = $AdLayoutContainer/SkinSelectContainer
@onready var skin_buttons: HFlowContainer = $AdLayoutContainer/SkinSelectContainer/ScrollContainer/InnerContainer/VBoxContainer/SkinButtons

@onready var locked_message_container: PanelContainer = $AdLayoutContainer/LockedMessageContainer
@onready var locked_message_description_label: Label = $AdLayoutContainer/LockedMessageContainer/ScrollContainer/InnerContainer/VBoxContainer/DescriptionLabel

const ICON_BUTTON = preload("uid://csw1duo5yljwy")
const LOCKED_ICON = preload("uid://bq331b3dfslw5")
const LEVEL_SELECT_THEME = preload("uid://dayndqrmaoq3i")
const DOG_THUMBNAIL = preload("uid://bp1qs2tnveae5")

var _current_hat : String

func _ready() -> void:
	color_picker_button.color_changed.connect(_on_color_changed)
	_current_hat = GlobalInputMap.Player_Hats_Selected[0]
	_hat.texture = GlobalInputMap.Player_Hats[_current_hat].player_hat
	update_visuals(GlobalInputMap.player_colors[0])
	
	locked_message_container.visible = false

	UINavigator.open.call_deferred(main_screen_container,false, false, _on_main_screen_back)
	hat_select_screen.visible = false
	hat_select_screen.visibility_changed.connect(_on_child_visibility_changed)
	locked_message_container.visibility_changed.connect(_on_child_visibility_changed)
	main_screen_container.visibility_changed.connect(_on_child_visibility_changed)
	
	_create_hat_buttons()
	_create_skin_buttons()

func _create_hat_buttons() -> void: 	
	var keys = GlobalInputMap.Player_Hats.keys()
	keys.sort_custom(func(a,b): 
			return GlobalInputMap.Player_Hats[a].unlocked > GlobalInputMap.Player_Hats[b].unlocked
			)
	
	for key:String in keys:
		var hat_info = GlobalInputMap.Player_Hats[key]
		var button : Button = ICON_BUTTON.instantiate()
		button.icon = hat_info.icon_hat
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hat_buttons.add_child(button)
		
		if !hat_info.unlocked: 
			var locked = LOCKED_ICON.instantiate()
			button.add_child(locked)
			button.pressed.connect(_on_locked_hat_pressed.bind(key))
		else:
			button.pressed.connect(_on_hat_selected.bind(key))
	hat_select_screen.visible = false

func _create_skin_buttons() -> void:
	var colors = GlobalInputMap.player_colors
	#colors.sort_custom(func(a,b): 
			#return GlobalInputMap.Player_Hats[a].unlocked > GlobalInputMap.Player_Hats[b].unlocked
			#)
	
	for c:Color in colors:
		var button : Button = ICON_BUTTON.instantiate()
		button.icon = DOG_THUMBNAIL
		button.modulate = c
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		skin_buttons.add_child(button)
		
		#if !hat_info.unlocked: 
			#var locked = LOCKED_ICON.instantiate()
			#button.add_child(locked)
			#button.pressed.connect(_on_locked_hat_pressed.bind(key))
		#else:
		button.pressed.connect(_on_color_changed.bind(c))
	hat_select_screen.visible = false
func update_visuals(new_color:Color) -> void:
	color_picker_button.color = new_color
	_head.self_modulate = new_color
	_legs.self_modulate = new_color
	text_edit.text = new_color.to_html()
	
func _on_main_screen_back() -> void:
	_confirm_choices()
	
	
func _on_color_changed(color:Color) -> void:
	update_visuals(color)
	UINavigator.back()
	

func _on_hat_selected(_hat_id:String) -> void:
	_current_hat = _hat_id
	_hat.texture = GlobalInputMap.Player_Hats[_current_hat].player_hat
	UINavigator.back()
	

func _on_locked_hat_pressed(_hat_id:String) -> void:
	locked_message_description_label.text = tr(_hat_id + "_UNLOCK_CONDITION")
	UINavigator.open(locked_message_container)


func _on_change_hat_pressed() -> void:
	UINavigator.open(hat_select_screen)
	

func _on_change_color_pressed() -> void:
	UINavigator.open(skin_select_screen)


func _on_red_slider_value_changed(value: float) -> void:
	var new_color: Color = _head.self_modulate
	new_color.r = value
	update_visuals(new_color)

	

func _on_green_slider_value_changed(value: float) -> void:
	var new_color: Color = _head.self_modulate
	new_color.g = value
	update_visuals(new_color)


func _on_blue_slider_value_changed(value: float) -> void:
	var new_color: Color = _head.self_modulate
	new_color.b = value
	update_visuals(new_color)


func _on_text_edit_text_changed() -> void:
	var new_color: Color = Color.from_string(text_edit.text, Color.WHITE)
	color_picker_button.color = new_color
	_head.self_modulate = new_color
	_legs.self_modulate = new_color

func _on_child_visibility_changed() -> void:
	if !main_screen_container.visible and !hat_select_screen.visible and !locked_message_container.visible:
		pass #_confirm_choices()
		
	
func _confirm_choices() -> void:
	if _head.self_modulate != GlobalInputMap.player_colors[0]:
		var new_color: Color = _head.self_modulate
		GlobalInputMap.player_colors.clear()
		GlobalInputMap.player_colors.append(new_color)
		GlobalInputMap.Player_Color_Selected[0] = 0
		GameSettings.on_dogColorChanged.emit(new_color)
		
	if _current_hat != GlobalInputMap.Player_Hats_Selected[0]:
		GlobalInputMap.Player_Hats_Selected[0] = _current_hat
		GameSettings.on_dogHatChanged.emit(_current_hat)
	UINavigator.back()
