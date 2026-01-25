extends AudioButton

func _ready() -> void:
	pressed.connect(UINavigator.back)
