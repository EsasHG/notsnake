extends AudioButton

func _ready() -> void:
	super()
	pressed.connect(_on_cloud_saves_pressed)
	
	
func _on_cloud_saves_pressed() -> void:
	SaveManager.show_cloud_saves()
