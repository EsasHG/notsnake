extends PanelContainer
@onready var color_picker_button: ColorPickerButton = $PanelContainer/VBoxContainer/HBoxContainer/ColorPickerButton
@onready var _head: AnimatedSprite2D = $PanelContainer/VBoxContainer/Control/Control/Head
@onready var _legs: AnimatedSprite2D = $PanelContainer/VBoxContainer/Control/Control/Head/Legs
@onready var back: Button = $PanelContainer/VBoxContainer/Back
@onready var hat_select_screen: Control = $HatSelectScreen
const LEVEL_SELECT_THEME = preload("uid://dayndqrmaoq3i")
@onready var hat_select_back: Button = $HatSelectScreen/VBoxContainer/ButtonContainer/Back
@onready var _hats_container: Node2D = $PanelContainer/VBoxContainer/Control/Control/Head/Hats
@onready var hat_buttons: HFlowContainer = $HatSelectScreen/VBoxContainer/PanelContainer/HatButtons

@export var hats : Array[CompressedTexture2D]
var _currentHat : int

func _ready() -> void:
	color_picker_button.color_changed.connect(_on_color_changed)
	color_picker_button.color = GlobalInputMap.player_colors[0]
	_head.self_modulate = GlobalInputMap.player_colors[0]
	_legs.self_modulate = GlobalInputMap.player_colors[0]
	back.grab_focus(false)
	
	for h in _hats_container.get_children():
		h.visible = false
	
	_currentHat = GlobalInputMap.Player_Hats_Selected[0]
	_hats_container.get_child(_currentHat).visible = true
	
	for i:int in hats.size():
		var button : Button = Button.new()
		button.theme = LEVEL_SELECT_THEME
		button.icon = hats[i]
		button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.expand_icon = true
		button.custom_minimum_size = Vector2(100,100)
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.focus_neighbor_bottom = hat_select_back.get_path()
		hat_buttons.add_child(button)
		button.pressed.connect(_on_hat_selected.bind(i))
	hat_select_screen.visible = false
	
	
func _on_color_changed(color:Color) -> void:
	_head.self_modulate = color
	_legs.self_modulate = color
	

func _on_back_pressed() -> void:
	if color_picker_button.color != GlobalInputMap.player_colors[0]:
		var new_color: Color = color_picker_button.color
		GlobalInputMap.player_colors.clear()
		GlobalInputMap.player_colors.append(color_picker_button.color)
		GlobalInputMap.Player_Color_Selected[0] = 0
		GameSettings.on_dogColorChanged.emit(new_color)
		
	if _currentHat != GlobalInputMap.Player_Hats_Selected[0]:
		GlobalInputMap.Player_Hats_Selected[0] = _currentHat
		GameSettings.on_dogHatChanged.emit(_currentHat)

func _on_hat_selected(_id:int) -> void:
	_currentHat = _id
	for c in _hats_container.get_children():
		c.visible = false
	_hats_container.get_child(_id).visible = true
	UINavigator.back()
	

func _on_change_hat_pressed() -> void:
	UINavigator.open(hat_select_screen,false)
