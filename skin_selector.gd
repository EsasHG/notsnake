extends PanelContainer
@onready var color_picker_button: ColorPickerButton = $MainScreen/VBoxContainer/HBoxContainer/ColorPickerButton
@onready var _head: AnimatedSprite2D = $MainScreen/VBoxContainer/Control/Control/Head
@onready var _legs: AnimatedSprite2D = $MainScreen/VBoxContainer/Control/Control/Head/Legs
@onready var _hat: Sprite2D = $MainScreen/VBoxContainer/Control/Control/Head/Hat
@onready var back: Button = $MainScreen/VBoxContainer/Back
@onready var hat_select_screen: Control = $HatSelectScreen
@onready var hat_select_back: Button = $HatSelectScreen/VBoxContainer/ButtonContainer/Back
@onready var hat_buttons: HFlowContainer = $HatSelectScreen/VBoxContainer/PanelContainer/HatButtons
@onready var main_screen_container: PanelContainer = $MainScreen
@onready var locked_message_container: PanelContainer = $LockedMessageContainer
@onready var text_edit: TextEdit = $MainScreen/VBoxContainer/HexEdit/TextEdit

const LOCKED_ICON = preload("uid://bq331b3dfslw5")
const LEVEL_SELECT_THEME = preload("uid://dayndqrmaoq3i")

var _current_hat : String

func _ready() -> void:
	color_picker_button.color_changed.connect(_on_color_changed)
	_current_hat = GlobalInputMap.Player_Hats_Selected[0]
	_hat.texture = GlobalInputMap.Player_Hats[_current_hat].player_hat
	update_visuals(GlobalInputMap.player_colors[0])
	back.grab_focus(false)
	
	locked_message_container.visible = false
	
	var keys = GlobalInputMap.Player_Hats.keys()
	keys.sort_custom(func(a,b): 
			return GlobalInputMap.Player_Hats[a].unlocked > GlobalInputMap.Player_Hats[b].unlocked
			)
	
	for key:String in keys:
		var hat_info = GlobalInputMap.Player_Hats[key]
		var button : Button = Button.new()
		button.theme = LEVEL_SELECT_THEME
		button.icon = hat_info.icon_hat
		button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.expand_icon = true
		button.custom_minimum_size = Vector2(180,180)
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.focus_neighbor_bottom = hat_select_back.get_path()
		hat_buttons.add_child(button)
		
		if !hat_info.unlocked: ##TODO: add actual logic here
			var locked = LOCKED_ICON.instantiate()
			button.add_child(locked)
			button.pressed.connect(_on_locked_hat_pressed.bind(key))
		else:
			button.pressed.connect(_on_hat_selected.bind(key))
	hat_select_screen.visible = false
	UINavigator.open.call_deferred(main_screen_container,false)
	
func update_visuals(new_color:Color) -> void:
	color_picker_button.color = new_color
	_head.self_modulate = new_color
	_legs.self_modulate = new_color
	text_edit.text = new_color.to_html()
	
	
func _on_color_changed(color:Color) -> void:
	update_visuals(color)
	

func _on_back_pressed() -> void:
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


func _on_hat_selected(_hat_id:String) -> void:
	_current_hat = _hat_id
	_hat.texture = GlobalInputMap.Player_Hats[_current_hat].player_hat
	UINavigator.back()
	

func _on_locked_hat_pressed(_hat_id:String) -> void:
	UINavigator.open(locked_message_container, false)


func _on_change_hat_pressed() -> void:
	UINavigator.open(hat_select_screen)
	

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

	
