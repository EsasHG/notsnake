extends Control
@onready var main_screen_container: PanelContainer = $AdLayoutContainer/MainScreen
@onready var _head: AnimatedSprite2D = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/VBoxContainer/Control/Control/Head
@onready var _legs: AnimatedSprite2D = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/VBoxContainer/Control/Control/Head/Legs
@onready var _hat: Sprite2D = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/VBoxContainer/Control/Control/Head/Hat

@onready var hat_select_screen: PanelContainer = $AdLayoutContainer/HatSelectContainer
@onready var hat_buttons: HFlowContainer = $AdLayoutContainer/HatSelectContainer/ScrollContainer/InnerContainer/VBoxContainer/HatButtons
@onready var skin_select_screen: PanelContainer = $AdLayoutContainer/SkinSelectContainer
@onready var treat_label: Label = $AdLayoutContainer/SkinSelectContainer/ScrollContainer/InnerContainer/VBoxContainer/TreatLabel
@onready var skin_buttons: HFlowContainer = $AdLayoutContainer/SkinSelectContainer/ScrollContainer/InnerContainer/VBoxContainer/SkinButtons
@onready var skin_purchase_buttons: HBoxContainer = $AdLayoutContainer/LockedMessageContainer/ScrollContainer/InnerContainer/VBoxContainer/SkinPurchaseButtons

@onready var locked_message_container: PanelContainer = $AdLayoutContainer/LockedMessageContainer
@onready var locked_message_description_label: Label = $AdLayoutContainer/LockedMessageContainer/ScrollContainer/InnerContainer/VBoxContainer/DescriptionLabel

const ICON_BUTTON = preload("uid://csw1duo5yljwy")
const LOCKED_ICON = preload("uid://bq331b3dfslw5")
const LEVEL_SELECT_THEME = preload("uid://dayndqrmaoq3i")
const DOG_THUMBNAIL = preload("uid://bp1qs2tnveae5")

var _current_hat : String
var _current_skin : String
var _considering_skin : String

func _ready() -> void:
	_current_hat = GlobalInputMap.Player_Hats_Selected[0]
	_current_skin = GlobalInputMap.Player_Skins_Selected[0]
	_hat.texture = GlobalInputMap.Player_Hats[_current_hat].player_hat
	update_visuals(_current_skin)
	
	locked_message_container.visible = false

	UINavigator.open.call_deferred(main_screen_container,false, false, _on_main_screen_back)
	hat_select_screen.visible = false
	hat_select_screen.visibility_changed.connect(_on_child_visibility_changed)
	locked_message_container.visibility_changed.connect(_on_child_visibility_changed)
	main_screen_container.visibility_changed.connect(_on_child_visibility_changed)
	_create_hat_buttons()
	_create_skin_buttons()
	
	skin_purchase_buttons.find_child("NoButton").pressed.connect(UINavigator.back)
	skin_purchase_buttons.find_child("YesButton").pressed.connect(_skin_purchased)
	skin_purchase_buttons.visible = false


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
	treat_label.text = tr("CURRENCY") + ": " + str(GameSettings.total_treats)
	
	for c in skin_buttons.get_children():
		c.queue_free()
		
	var skin_names = GlobalInputMap.player_skins.keys()
	skin_names.sort_custom(func(a,b): 
			if (GlobalInputMap.player_skins[a].unlocked || GlobalInputMap.player_skins[b].unlocked):
				return GlobalInputMap.player_skins[a].unlocked > GlobalInputMap.player_skins[b].unlocked
			else:
				return GlobalInputMap.player_skins[a].price < GlobalInputMap.player_skins[b].price
			)
	for key in skin_names:
		var skin:DogSkin = GlobalInputMap.player_skins[key]
		var button : Button = ICON_BUTTON.instantiate()
		button.icon = skin.head.get_frame_texture("default",0)
		button.self_modulate = skin.modulate
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		skin_buttons.add_child(button)
		
		if !skin.unlocked: 
			var locked = LOCKED_ICON.instantiate()
			button.add_child(locked)
			button.pressed.connect(_on_locked_skin_pressed.bind(key))
			var label = Label.new()
			label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE,Control.PRESET_MODE_KEEP_SIZE)
			label.position.y-= 28
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.text = str(skin.price) + " " + tr("CURRENCY")
			label.add_theme_font_size_override("font_size", 24)
			button.add_child(label)
		else:
			button.pressed.connect(_on_skin_selected.bind(key))
	hat_select_screen.visible = false


func update_visuals(skin_id:String) -> void:
	var skin:DogSkin = GlobalInputMap.player_skins[skin_id]
	_head.sprite_frames = skin.head
	_legs.sprite_frames = skin.legs_front
	_head.self_modulate = skin.modulate
	_legs.self_modulate = skin.modulate
	

func _on_main_screen_back() -> void:
	_confirm_choices()
	
	
func _on_skin_selected(skin_id:String) -> void:
	_current_skin = skin_id
	update_visuals(skin_id)
	UINavigator.back()
	

func _on_hat_selected(_hat_id:String) -> void:
	_current_hat = _hat_id
	_hat.texture = GlobalInputMap.Player_Hats[_current_hat].player_hat
	UINavigator.back()
	

func _on_locked_hat_pressed(_hat_id:String) -> void:
	locked_message_description_label.text = tr(_hat_id + "_UNLOCK_CONDITION")
	UINavigator.open(locked_message_container)


func _on_locked_skin_pressed(skin_id:String) -> void:
	var skin:DogSkin = GlobalInputMap.player_skins[skin_id]
	if skin.price > GameSettings.total_treats:
		locked_message_description_label.text = tr("SKIN_UNAFFORDABLE") % skin.price
	else:
		locked_message_description_label.text = tr("UNLOCK_SKIN") % skin.price
		skin_purchase_buttons.visible = true
		_considering_skin = skin_id
		
	UINavigator.open(locked_message_container,true, false, func(): 
		skin_purchase_buttons.visible = false
		_considering_skin = ""
		)
	

func _skin_purchased() -> void:
	if _considering_skin.is_empty():
		Logging.error("Skin purchased was called, but _considering_skin is empty!")
		return

	var skin = GlobalInputMap.player_skins[_considering_skin]
		
	skin.unlocked = true
	GameSettings.total_treats -= skin.price
	
	_create_skin_buttons()
	_on_skin_selected(_considering_skin)
	UINavigator.back()
	
func _on_change_hat_pressed() -> void:
	UINavigator.open(hat_select_screen)
	

func _on_change_color_pressed() -> void:
	UINavigator.open(skin_select_screen)


func _on_child_visibility_changed() -> void:
	if !main_screen_container.visible and !hat_select_screen.visible and !locked_message_container.visible:
		pass #_confirm_choices()
		
	
func _confirm_choices() -> void:
	if _current_skin != GlobalInputMap.Player_Skins_Selected[0]:
		var new_color: Color = _head.self_modulate
		GlobalInputMap.Player_Skins_Selected[0] = _current_skin
		GameSettings.on_dogSkinChanged.emit(_current_skin)
	if _current_hat != GlobalInputMap.Player_Hats_Selected[0]:
		GlobalInputMap.Player_Hats_Selected[0] = _current_hat
		GameSettings.on_dogHatChanged.emit(_current_hat)
	UINavigator.back()
