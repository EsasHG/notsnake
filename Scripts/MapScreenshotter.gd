extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_generate_icon() # Replace with function body.

func _generate_icon():
	for child in get_children():
		await RenderingServer.frame_post_draw
		var img = child.get_texture().get_image()
		img.save_png("res://Assets/Icons/" + child.name +".png")
