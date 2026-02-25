extends PopupContainer

class_name ConflictPopup

@onready var local_save_container: VBoxContainer = $OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/HSplitContainer/LocalSaveContainer
@onready var server_save_container: VBoxContainer = $OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/HSplitContainer/ServerSaveContainer
@onready var local_save_title: Label = $OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/HSplitContainer/LocalSaveContainer/TitleLabel
@onready var local_save_time: Label = $OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/HSplitContainer/LocalSaveContainer/TimestampLabel
@onready var choose_local_button: Button = $OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/HSplitContainer/LocalSaveContainer/ChooseButton

@onready var server_save_title: Label = $OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/HSplitContainer/ServerSaveContainer/TitleLabel
@onready var server_save_time: Label = $OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/HSplitContainer/ServerSaveContainer/TimestampLabel
@onready var choose_server_button: Button = $OuterPanelContainer/ScrollContainer/InnerContainer/VBoxContainer/HSplitContainer/ServerSaveContainer/ChooseButton
