extends Control

@onready var fake_dog: Node2D = $AdLayoutContainer/MarginContainer/VBoxContainer/DogVisual/HBoxContainer/Control/Control/FakeDog
@onready var hat_select_screen: VBoxContainer = $AdLayoutContainer/MarginContainer/VBoxContainer/SkinSelection/ChoicePanel/ScrollContainer/InnerContainer/HatSelectContainer
@onready var skin_select_screen: VBoxContainer = $AdLayoutContainer/MarginContainer/VBoxContainer/SkinSelection/ChoicePanel/ScrollContainer/InnerContainer/SkinSelectContainer

@onready var locked_message_container: VBoxContainer = $AdLayoutContainer/MarginContainer/VBoxContainer/SkinSelection/ChoicePanel/ScrollContainer/InnerContainer/LockedMessageContainer
@onready var locked_message_title_label: Label = $AdLayoutContainer/MarginContainer/VBoxContainer/SkinSelection/ChoicePanel/ScrollContainer/InnerContainer/LockedMessageContainer/TitleLabel
@onready var locked_message_description_label: Label = $AdLayoutContainer/MarginContainer/VBoxContainer/SkinSelection/ChoicePanel/ScrollContainer/InnerContainer/LockedMessageContainer/DescriptionLabel
@onready var skin_purchase_buttons: HBoxContainer = $AdLayoutContainer/MarginContainer/VBoxContainer/SkinSelection/ChoicePanel/ScrollContainer/InnerContainer/LockedMessageContainer/SkinPurchaseButtons



const ICON_BUTTON = preload("uid://csw1duo5yljwy")
const LOCKED_ICON = preload("uid://bq331b3dfslw5")
const LEVEL_SELECT_THEME = preload("uid://dayndqrmaoq3i")
const DOG_THUMBNAIL = preload("uid://bp1qs2tnveae5")

var _current_hat : String
var _current_dog : String
var _current_skin : String
var _considering_item : String
var _changes_made : bool = false

func _ready() -> void:
	_current_hat = GlobalInputMap.hats_selected[0]
	_current_dog = GlobalInputMap.dogs_selected[0]
	_current_skin = GlobalInputMap.skins_selected[0]
	fake_dog.set_skin(_current_dog, _current_skin)
	fake_dog.set_hat(_current_hat)
	
	locked_message_container.visible = false

	hat_select_screen.visible = false
	skin_select_screen.visible = true
	_create_hat_buttons()
	_create_skin_buttons()
	
	skin_purchase_buttons.find_child("NoButton").pressed.connect(UINavigator.back)
	skin_purchase_buttons.find_child("YesButton").pressed.connect(_item_purchased)
	skin_purchase_buttons.visible = false


func _create_hat_buttons() -> void:
	for c in hat_select_screen.get_child(2).get_children():
		c.queue_free()
	
	var keys = GlobalInputMap.hats.keys()
	keys.sort_custom(func(a,b): 
			return GlobalInputMap.hats[a].unlocked > GlobalInputMap.hats[b].unlocked
			)
	
	for key:String in keys:
		hat_select_screen.get_child(1).text = tr("CURRENCY") + ": " + str(GameSettings.total_treats)
		
		var hat_info:Dictionary = GlobalInputMap.hats[key]
		var button : Button = ICON_BUTTON.instantiate()
		button.icon = hat_info.texture
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hat_select_screen.get_child(2).add_child(button)
		
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
	skin_select_screen.get_child(1).text = tr("CURRENCY") + ": " + str(GameSettings.total_treats)
	
	for c in skin_select_screen.get_child(2).get_children():
		c.queue_free()
		
	var skin_names = GlobalInputMap.dogs[_current_dog].keys()
	skin_names.sort_custom(func(a,b): 
			if (GlobalInputMap.dogs[_current_dog][a].unlocked || GlobalInputMap.dogs[_current_dog][b].unlocked):
				return GlobalInputMap.dogs[_current_dog][a].unlocked > GlobalInputMap.dogs[_current_dog][b].unlocked
			else:
				return GlobalInputMap.dogs[_current_dog][a].price < GlobalInputMap.dogs[_current_dog][b].price
			)
	for key in skin_names:
		var skin:DogSkin = GlobalInputMap.dogs[_current_dog][key]
		var button : Button = ICON_BUTTON.instantiate()
		button.icon = skin.icon
		button.self_modulate = skin.modulate
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		skin_select_screen.get_child(2).add_child(button)
		
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


func _on_main_screen_back() -> void:
	_confirm_choices()
	
	
func _on_skin_selected(skin_id:String) -> void:
	if skin_id != _current_skin:
		_current_skin = skin_id
		_changes_made = true
		fake_dog.set_skin(_current_dog, skin_id)
	
	UINavigator.back()
	

func _on_hat_selected(_hat_id:String) -> void:
	if _hat_id != _current_hat:
		_current_hat = _hat_id
		var new_hat = GlobalInputMap.hats[_current_hat]
		fake_dog.set_hat(new_hat)
		_changes_made = true
	UINavigator.back()
	

func _on_locked_hat_pressed(_hat_id:String) -> void:
	locked_message_title_label.text = tr("HAT_LOCKED")
	locked_message_description_label.text = tr(_hat_id + "_UNLOCK_CONDITION")
	UINavigator.open(locked_message_container)


func _on_locked_item_pressed(item_id:String) -> void:
	var item
	if GlobalInputMap.hats.has(item_id):
		locked_message_title_label.text = tr("HAT_LOCKED")
		item = GlobalInputMap.hats[item_id]
	elif GlobalInputMap.dogs[_current_dog].has(item_id):
		locked_message_title_label.text = tr("SKIN_LOCKED")
		item = GlobalInputMap.dogs[_current_dog][item_id]
	else:
		Logging.error("Locked item '" +_considering_item + "' is not a hat or a skin for dog " + _current_dog + "!") 
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
	if GlobalInputMap.dogs[_current_dog].has(_considering_item):
		item = GlobalInputMap.dogs[_current_dog][_considering_item]
	elif GlobalInputMap.hats.has(_considering_item):
		item = GlobalInputMap.hats[_considering_item]
	else:
		Logging.error("Purchased item '" +_considering_item + "' is not a hat or a skin for dog " + _current_dog + "!") 
	item.unlocked = true
	GameSettings.total_treats -= item.price
	_create_skin_buttons()
	_create_hat_buttons()
	SaveManager.save_game()
	UINavigator.back()
	
	
func _on_change_hat_pressed() -> void:
	UINavigator.open(hat_select_screen)
	

func _on_change_color_pressed() -> void:
	UINavigator.open(skin_select_screen)


#func _on_child_visibility_changed() -> void:
	#if !main_screen_container.visible and !hat_select_screen.visible and !locked_message_container.visible:
		#pass #_confirm_choices()
		
	
func _confirm_choices() -> void:
	if _current_skin != GlobalInputMap.skins_selected[0]:
		GlobalInputMap.skins_selected[0] = _current_skin
		GameSettings.on_dogSkinChanged.emit(_current_skin)
	if _current_hat != GlobalInputMap.hats_selected[0]:
		GlobalInputMap.hats_selected[0] = _current_hat
		GameSettings.on_dogHatChanged.emit(_current_hat)
	if _changes_made:
		SaveManager.save_game()
	UINavigator.back()


func _on_color_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		skin_select_screen.visible = true
		hat_select_screen.visible = false
		locked_message_container.visible = false
	else:
		skin_select_screen.visible = false
		hat_select_screen.visible = true
		locked_message_container.visible = false
