extends Control
@onready var main_screen_container: VBoxContainer = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/MainContainer
@onready var _head: AnimatedSprite2D = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/MainContainer/Control/Control/Head
@onready var _legs: AnimatedSprite2D = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/MainContainer/Control/Control/Head/Legs
@onready var _hat: Sprite2D = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/MainContainer/Control/Control/Head/Hat

@onready var hat_select_screen: VBoxContainer = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/HatSelectContainer
@onready var hat_buttons: HFlowContainer = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/HatSelectContainer/HatButtons
@onready var hat_treat_label: Label = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/HatSelectContainer/HatTreatLabel

@onready var skin_select_screen: VBoxContainer = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/SkinSelectContainer
@onready var treat_label: Label = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/SkinSelectContainer/TreatLabel
@onready var skin_buttons: HFlowContainer = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/SkinSelectContainer/SkinButtons
@onready var skin_purchase_buttons: HBoxContainer = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/LockedMessageContainer/SkinPurchaseButtons
@onready var locked_message_container: VBoxContainer = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/LockedMessageContainer
@onready var locked_message_title_label: Label = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/LockedMessageContainer/TitleLabel
@onready var locked_message_description_label: Label = $AdLayoutContainer/MainScreen/ScrollContainer/InnerContainer/LockedMessageContainer/DescriptionLabel


const ICON_BUTTON = preload("uid://csw1duo5yljwy")
const LOCKED_ICON = preload("uid://bq331b3dfslw5")
const LEVEL_SELECT_THEME = preload("uid://dayndqrmaoq3i")
const DOG_THUMBNAIL = preload("uid://bp1qs2tnveae5")

var _current_hat : String
var _current_skin : String
var _considering_item : String

func _ready() -> void:
	_current_hat = GlobalInputMap.hats_selected[0]
	_current_skin = GlobalInputMap.skins_selected[0]
	_hat.texture = GlobalInputMap.hats[_current_hat].texture
	_hat.position = GlobalInputMap.skins[_current_skin].hat_offset + GlobalInputMap.hats[_current_hat].offset
	
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
	skin_purchase_buttons.find_child("YesButton").pressed.connect(_item_purchased)
	skin_purchase_buttons.visible = false


func _create_hat_buttons() -> void:
	var keys = GlobalInputMap.hats.keys()
	keys.sort_custom(func(a,b): 
			return GlobalInputMap.hats[a].unlocked > GlobalInputMap.hats[b].unlocked
			)
	
	for key:String in keys:
		hat_treat_label.text = tr("CURRENCY") + ": " + str(GameSettings.total_treats)
		
		var hat_info:Dictionary = GlobalInputMap.hats[key]
		var button : Button = ICON_BUTTON.instantiate()
		button.icon = hat_info.texture
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hat_buttons.add_child(button)
		
		if !hat_info.unlocked: 
			var locked = LOCKED_ICON.instantiate()
			button.add_child(locked)
			
			if hat_info.has("price"):
				var label = Label.new()
				label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE,Control.PRESET_MODE_KEEP_SIZE)
				label.position.y-= 28
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				label.text = str(hat_info.price) + " " + tr("CURRENCY")
				label.add_theme_font_size_override("font_size", 24)
				button.add_child(label)
				button.pressed.connect(_on_locked_item_pressed.bind(key))
			else:
				button.pressed.connect(_on_locked_hat_pressed.bind(key))
				
		else:
			button.pressed.connect(_on_hat_selected.bind(key))
	hat_select_screen.visible = false

	
func _create_skin_buttons() -> void:
	treat_label.text = tr("CURRENCY") + ": " + str(GameSettings.total_treats)
	
	for c in skin_buttons.get_children():
		c.queue_free()
		
	var skin_names = GlobalInputMap.skins.keys()
	skin_names.sort_custom(func(a,b): 
			if (GlobalInputMap.skins[a].unlocked || GlobalInputMap.skins[b].unlocked):
				return GlobalInputMap.skins[a].unlocked > GlobalInputMap.skins[b].unlocked
			else:
				return GlobalInputMap.skins[a].price < GlobalInputMap.skins[b].price
			)
	for key in skin_names:
		var skin:DogSkin = GlobalInputMap.skins[key]
		var button : Button = ICON_BUTTON.instantiate()
		button.icon = skin.head.get_frame_texture("default",0)
		button.self_modulate = skin.modulate
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		skin_buttons.add_child(button)
		
		if !skin.unlocked: 
			var locked = LOCKED_ICON.instantiate()
			button.add_child(locked)
			button.pressed.connect(_on_locked_item_pressed.bind(key))
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
	var skin:DogSkin = GlobalInputMap.skins[skin_id]
	_head.sprite_frames = skin.head
	_legs.sprite_frames = skin.legs_front
	_head.self_modulate = skin.modulate
	_legs.self_modulate = skin.modulate
	_hat.position = skin.hat_offset + GlobalInputMap.hats[_current_hat].offset
	

func _on_main_screen_back() -> void:
	_confirm_choices()
	
	
func _on_skin_selected(skin_id:String) -> void:
	_current_skin = skin_id
	update_visuals(skin_id)
	UINavigator.back()
	

func _on_hat_selected(_hat_id:String) -> void:
	_current_hat = _hat_id
	var new_hat = GlobalInputMap.hats[_current_hat]
	_hat.texture = new_hat.texture
	_hat.position = new_hat.offset + GlobalInputMap.skins[_current_skin].hat_offset
	UINavigator.back()
	

func _on_locked_hat_pressed(_hat_id:String) -> void:
	locked_message_title_label.text = tr("HAT_LOCKED")
	locked_message_description_label.text = tr(_hat_id + "_UNLOCK_CONDITION")
	UINavigator.open(locked_message_container)


func _on_locked_item_pressed(item_id:String) -> void:
	var item 
	if GlobalInputMap.skins.has(item_id):
		locked_message_title_label.text = tr("SKIN_LOCKED")
		item = GlobalInputMap.skins[item_id]
	elif GlobalInputMap.hats.has(item_id):
		locked_message_title_label.text = tr("HAT_LOCKED")
		item = GlobalInputMap.hats[item_id]
	else:
		Logging.error("Locked item '" +_considering_item + "' is not a skin or a hat!") 
	if item.price > GameSettings.total_treats:
		locked_message_description_label.text = tr("ITEM_UNAFFORDABLE") % item.price
	else:
		locked_message_description_label.text = tr("UNLOCK_ITEM") % item.price
		skin_purchase_buttons.visible = true
		_considering_item = item_id
		
	UINavigator.open(locked_message_container,true, false, func(): 
		skin_purchase_buttons.visible = false
		_considering_item = ""
		)
	

func _item_purchased() -> void:
	if _considering_item.is_empty():
		Logging.error("Skin purchased was called, but _considering_skin is empty!")
		return
	var item
	if GlobalInputMap.skins.has(_considering_item):
		item = GlobalInputMap.skins[_considering_item]
	elif GlobalInputMap.hats.has(_considering_item):
		item = GlobalInputMap.hats[_considering_item]
	else:
		Logging.error("Purchased item '" +_considering_item + "' is not a skin or a hat!") 
	item.unlocked = true
	GameSettings.total_treats -= item.price
	_create_skin_buttons()
	_create_hat_buttons()
	UINavigator.back()
	
	
func _on_change_hat_pressed() -> void:
	UINavigator.open(hat_select_screen)
	

func _on_change_color_pressed() -> void:
	UINavigator.open(skin_select_screen)


func _on_child_visibility_changed() -> void:
	if !main_screen_container.visible and !hat_select_screen.visible and !locked_message_container.visible:
		pass #_confirm_choices()
		
	
func _confirm_choices() -> void:
	if _current_skin != GlobalInputMap.skins_selected[0]:
		var new_color: Color = _head.self_modulate
		GlobalInputMap.skins_selected[0] = _current_skin
		GameSettings.on_dogSkinChanged.emit(_current_skin)
	if _current_hat != GlobalInputMap.hats_selected[0]:
		GlobalInputMap.hats_selected[0] = _current_hat
		GameSettings.on_dogHatChanged.emit(_current_hat)
	UINavigator.back()
