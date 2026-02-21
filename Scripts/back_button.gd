extends AudioButton

func _ready() -> void:
	streamPlayerName = "UI_Back"
	super()
	pressed.connect(UINavigator.back)
