@tool
extends SubViewportContainer
@onready var camera_2d: Camera2D = $SubViewport/Camera2D
@export var zoom_amount:float = 0.1
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				camera_2d.zoom += Vector2(zoom_amount,zoom_amount)
				# Insert zoom in or scroll up logic here
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				camera_2d.zoom -= Vector2(zoom_amount,zoom_amount)
				accept_event()
				# Insert zoom out or scroll down logic here
