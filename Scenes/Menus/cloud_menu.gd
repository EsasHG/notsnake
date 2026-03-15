extends PopupContainer

@onready var save_name_line_edit: LineEdit = $OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/HBoxContainer/SaveNameLineEdit
@onready var create_save_button: AudioButton = $OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/CreateSave
@onready var save_name_label: Label = $OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/SaveNameLabel

const POPUP_MENU = preload("uid://chupiwnqy5234")
func _ready() -> void:
	super()
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if visible: 
		create_save_button.disabled = false
		

func _on_create_save_pressed() -> void:
	create_save_button.disabled = true
	var save_name =  save_name_line_edit.text.strip_edges().strip_escapes()
	save_name.is_valid_ascii_identifier()
	if save_name.is_empty():
		save_name = save_name_line_edit.placeholder_text.strip_edges().strip_escapes()
	SaveManager.game_saved.connect(_on_game_saved)
	SaveManager.create_cloud_save()


func _on_game_saved(success:bool, to_cloud:bool) -> void:
	var popup:PopupContainer = UINavigator.open_from_scene(POPUP_MENU, true,false, UINavigator.back)
	if not to_cloud:
		popup.title.text = tr("SAVE_CREATE_ERROR")
		popup.description.text = tr("SAVE_CREATE_UNKNOWN_ERROR_DESCRIPTION")
	elif success:
		popup.title.text = tr("SAVE_CREATED")
		popup.description.text = tr("SAVE_CREATED_DESCRIPTION")
		


func _on_disable_cloud_pressed() -> void:
	UINavigator.back()
	pass # Replace with function body.
