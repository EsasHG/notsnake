@tool
extends SubViewportContainer

@export_tool_button("Generate Icons") var generate_icons_button = generate_icon
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_icon() # Replace with function body.

func generate_icon():
	print("generating icons...")
	for child in get_children():
		await RenderingServer.frame_post_draw
		var img = child.get_texture().get_image()
		img.save_png("res://Assets/Icons/" + child.name +".png")
		print("Icon generated: " + child.name)
