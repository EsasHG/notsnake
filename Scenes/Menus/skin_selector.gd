extends Control

@onready var fake_dog: Node2D = $MarginContainer/VBoxContainer/DogVisual/HBoxContainer/Control/Control/FakeDog
@onready var color_select_screen: VBoxContainer = $MarginContainer/VBoxContainer/SkinSelection/ChoicePanel/VBoxContainer/ScrollContainer/InnerContainer/ColorSelectContainer
@onready var hat_select_screen: VBoxContainer = $MarginContainer/VBoxContainer/SkinSelection/ChoicePanel/VBoxContainer/ScrollContainer/InnerContainer/HatSelectContainer

@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer
@onready var h_box_container: HBoxContainer = $MarginContainer/HBoxContainer
@onready var locked_message_container: VBoxContainer = $MarginContainer/VBoxContainer/SkinSelection/ChoicePanel/VBoxContainer/ScrollContainer/InnerContainer/LockedMessageContainer
@onready var skin_purchase_buttons: HBoxContainer = $MarginContainer/VBoxContainer/SkinSelection/ChoicePanel/VBoxContainer/ScrollContainer/InnerContainer/LockedMessageContainer/SkinPurchaseButtons
@onready var dog_visual: VBoxContainer = $MarginContainer/VBoxContainer/DogVisual
@onready var skin_selection: VBoxContainer = $MarginContainer/VBoxContainer/SkinSelection
@onready var locked_message_title_label: Label = $MarginContainer/VBoxContainer/SkinSelection/ChoicePanel/VBoxContainer/ScrollContainer/InnerContainer/LockedMessageContainer/TitleLabel
@onready var locked_message_description_label: Label = $MarginContainer/VBoxContainer/SkinSelection/ChoicePanel/VBoxContainer/ScrollContainer/InnerContainer/LockedMessageContainer/DescriptionLabel
@onready var color_button: AudioButton = $MarginContainer/VBoxContainer/SkinSelection/ChoicePanel/VBoxContainer/PanelContainer/TabButtons/ColorButton
@onready var hat_button: AudioButton = $MarginContainer/VBoxContainer/SkinSelection/ChoicePanel/VBoxContainer/PanelContainer/TabButtons/HatButton
@onready var treat_label: Label = $MarginContainer/VBoxContainer/SkinSelection/ChoicePanel/VBoxContainer/TreatLabel

@onready var locked_back_button: Button = $MarginContainer/VBoxContainer/SkinSelection/ChoicePanel/VBoxContainer/ScrollContainer/InnerContainer/LockedMessageContainer/BackButton

const ICON_BUTTON = preload("uid://csw1duo5yljwy")
const LOCKED_ICON = preload("uid://bq331b3dfslw5")
const LEVEL_SELECT_THEME = preload("uid://dayndqrmaoq3i")
const DOG_THUMBNAIL = preload("uid://bp1qs2tnveae5")

var _current_hat : String
var _current_dog : String
var _visible_dog_index : int = 0
var _current_skin : String
var _considering_item : String
var _changes_made : bool = false


func _ready() -> void:
	_current_hat = GlobalInputMap.hats_selected[0]
	_current_dog = GlobalInputMap.dogs_selected[0]
	_current_skin = GlobalInputMap.skins_selected[0]
	
	var i : int = 0
	for dog in GlobalInputMap.dogs:
		if dog == _current_dog:
			_visible_dog_index = i
			break
		else:
			i+= 1
			
	fake_dog.set_skin(_current_dog, _current_skin)
	fake_dog.set_hat(_current_hat)
	
	locked_message_container.visible = false

	hat_select_screen.visible = false
	color_select_screen.visible = true
	_create_hat_buttons()
	_create_skin_buttons()
	
	dog_visual.visible = true
	skin_selection.visible = true
	
	skin_purchase_buttons.find_child("YesButton").pressed.connect(_item_purchased)
	skin_purchase_buttons.find_child("NoButton").pressed.connect(_locked_container_back)
	skin_purchase_buttons.visible = false
	GameSettings.on_viewportChanged.connect(_on_viewport_changed)
	_on_viewport_changed()
	
	locked_message_container.visibility_changed.connect(func():
		if locked_message_container.visible:
			color_button.disabled = true
			hat_button.disabled = true
		else:
			color_button.disabled = false
			hat_button.disabled = false
				)
	color_select_screen.visible = true
	hat_select_screen.visible = false
	locked_message_container.visible = false
	#UINavigator.open(color_select_screen,false,true, UINavigator.back)
	

func _on_viewport_changed() -> void:
	if GameSettings.viewport_mode == GameSettings.VIEWPORT_MODE.PORTRAIT:
		v_box_container.visible = true
		dog_visual.reparent(v_box_container)
		dog_visual.size_flags_horizontal = Control.SIZE_FILL
		dog_visual.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		skin_selection.reparent(v_box_container)
		h_box_container.visible = false
	else:
		h_box_container.visible = true
		dog_visual.reparent(h_box_container)
		dog_visual.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		dog_visual.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		skin_selection.reparent(h_box_container)
		v_box_container.visible = false

func _create_hat_buttons() -> void:
	var hat_button_container = hat_select_screen.get_child(0)
	for c in hat_button_container.get_children():
		c.queue_free()
	
	var keys = GlobalInputMap.hats.keys()
	keys.sort_custom(func(a,b): 
			return GlobalInputMap.hats[a].unlocked > GlobalInputMap.hats[b].unlocked
			)
	
	for key:String in keys:
		treat_label.text = tr("CURRENCY") + ": " + str(GameSettings.total_treats)
		
		var hat_info:Dictionary = GlobalInputMap.hats[key]
		var button : Button = ICON_BUTTON.instantiate()
		button.icon = hat_info.texture
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hat_button_container.add_child(button)
		
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
	var color_button_container = color_select_screen.get_child(0)
	for c in color_button_container.get_children():
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
		color_button_container.add_child(button)
		
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
	

func _on_hat_selected(_hat_id:String) -> void:
	if _hat_id != _current_hat:
		_current_hat = _hat_id
		fake_dog.set_hat(_current_hat)
		_changes_made = true
	

func _on_locked_hat_pressed(_hat_id:String) -> void:
	locked_message_title_label.text = tr("HAT_LOCKED")
	locked_message_description_label.text = tr(_hat_id + "_UNLOCK_CONDITION")
	hat_select_screen.visible = false
	color_select_screen.visible = false
	locked_message_container.visible = true
	skin_purchase_buttons.visible = false
	locked_back_button.visible = true
	#UINavigator.open(locked_message_container)


func _on_locked_item_pressed(item_id:String) -> void:
	var item
	if GlobalInputMap.hats.has(item_id):
		locked_message_title_label.text = tr("HAT_LOCKED")
		item = GlobalInputMap.hats[item_id]
	elif GlobalInputMap.dogs.has(item_id):
		locked_message_title_label.text = tr("SKIN_LOCKED")
		item = GlobalInputMap.dogs[item_id].values().front()
	elif GlobalInputMap.dogs[_current_dog].has(item_id):
		locked_message_title_label.text = tr("SKIN_LOCKED")
		item = GlobalInputMap.dogs[_current_dog][item_id]
	else:
		Logging.error("Locked item '" +_considering_item + "' is not a hat or a skin for dog " + _current_dog + "!") 
	
	if item.price > GameSettings.total_treats:
		locked_message_description_label.text = tr("ITEM_UNAFFORDABLE") % item.price
		skin_purchase_buttons.visible = false
		locked_back_button.visible = true
	else:
		locked_message_description_label.text = tr("UNLOCK_ITEM") % item.price
		skin_purchase_buttons.visible = true
		locked_back_button.visible = false
		_considering_item = item_id
	
	treat_label.text = tr("CURRENCY") + ": " + str(GameSettings.total_treats)
	locked_message_container.visible = true
	color_select_screen.visible = false
	hat_select_screen.visible = false
	#if ! locked_message_container.visible:
		#UINavigator.open(locked_message_container,true, false, func(): 
			#skin_purchase_buttons.visible = false
			#_considering_item = ""
			#)
	

func _item_purchased() -> void:
	if _considering_item.is_empty():
		Logging.error("Skin purchased was called, but _considering_skin is empty!")
		return
	var item
	if GlobalInputMap.dogs.has(_considering_item):
		item = GlobalInputMap.dogs[_considering_item].values().front()
		_current_dog = _considering_item
		_on_skin_selected(GlobalInputMap.dogs[_considering_item].keys().front())
		
	elif GlobalInputMap.dogs[_current_dog].has(_considering_item):
		item = GlobalInputMap.dogs[_current_dog][_considering_item]
		_on_skin_selected(_considering_item)
	elif GlobalInputMap.hats.has(_considering_item):
		item = GlobalInputMap.hats[_considering_item]
		_on_hat_selected(_considering_item)
	else:
		Logging.error("Purchased item '" +_considering_item + "' is not a dog, hat, or a skin for dog " + _current_dog + "!") 
	item.unlocked = true
	GameSettings.total_treats -= item.price
	_create_skin_buttons()
	_create_hat_buttons()
	SaveManager.save_game()
	_locked_container_back()
	
	
func _locked_container_back() -> void:
	locked_message_container.visible = false
	_considering_item = ""
	if color_button.button_pressed:
		color_select_screen.visible = true
		hat_select_screen.visible = false
	else:
		color_select_screen.visible = false
		hat_select_screen.visible = true


func _on_change_hat_pressed() -> void:
	color_select_screen.visible = false
	hat_select_screen.visible = true
	locked_message_container.visible = false	


func _on_change_color_pressed() -> void:
	color_select_screen.visible = true
	hat_select_screen.visible = false
	locked_message_container.visible = false


func _confirm_choices() -> void:
	if _current_dog != GlobalInputMap.dogs_selected[0]:
		GlobalInputMap.dogs_selected[0] = _current_dog
	if _current_skin != GlobalInputMap.skins_selected[0]:
		GlobalInputMap.skins_selected[0] = _current_skin
	if _current_hat != GlobalInputMap.hats_selected[0]:
		GlobalInputMap.hats_selected[0] = _current_hat
		GameSettings.on_dogHatChanged.emit(_current_hat)
	if _changes_made:
		GameSettings.on_dogSkinChanged.emit(_current_dog,_current_skin)
		SaveManager.save_game()
	UINavigator.back()


func _on_color_button_toggled(toggled_on: bool) -> void:
	print("Toggled!")
	if toggled_on && !color_select_screen.visible:
		color_select_screen.visible = true
		hat_select_screen.visible = false
		locked_message_container.visible = false
	elif !toggled_on && !hat_select_screen.visible:
		color_select_screen.visible = false
		hat_select_screen.visible = true
		locked_message_container.visible = false
		

func _on_left_arrow_pressed() -> void:
	_visible_dog_index = _visible_dog_index-1 if _visible_dog_index >0 else GlobalInputMap.dogs.size()-1 
	var new_dog : String = GlobalInputMap.dogs.keys()[_visible_dog_index]
	Logging.logMessage("Index: " + str(_visible_dog_index) + " Name: " + new_dog)
	var skin_id = GlobalInputMap.dogs[new_dog].keys().front()
	fake_dog.set_skin(new_dog, skin_id)
	if GlobalInputMap.dogs[new_dog][skin_id].unlocked:
		_current_dog = new_dog
		_current_skin = GlobalInputMap.dogs[new_dog].keys().front()
		_changes_made = true
		_create_skin_buttons()
		if locked_message_container.visible:
			_locked_container_back()
	else:
		_on_locked_item_pressed(new_dog)
		
	
func _on_right_arrow_pressed() -> void:
	_visible_dog_index = _visible_dog_index+1 if _visible_dog_index < GlobalInputMap.dogs.size()-1 else 0 
	var new_dog : String = GlobalInputMap.dogs.keys()[_visible_dog_index]
	Logging.logMessage("Index: " + str(_visible_dog_index) + " Name: " + new_dog)
	var skin_id = GlobalInputMap.dogs[new_dog].keys().front()
	fake_dog.set_skin(new_dog, skin_id)
	if GlobalInputMap.dogs[new_dog][skin_id].unlocked:
		_current_dog = new_dog
		_current_skin = GlobalInputMap.dogs[new_dog].keys().front()
		_changes_made = true
		_create_skin_buttons()
		if locked_message_container.visible:
			_locked_container_back()
	else:
		_considering_item = new_dog
		_on_locked_item_pressed(new_dog)


func _on_close_button_pressed() -> void:
	_confirm_choices()
	UINavigator.force_back()
