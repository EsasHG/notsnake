#@tool
extends Sprite2D

@export var path_2d: Path2D
@export var path_sprite : Sprite2D
@onready var sub_viewport: SubViewport = $"../../SubViewport"

func _ready() -> void:
	var image = Image.create(3800, 6300, false, Image.FORMAT_RGB8)

	path_sprite.texture = ImageTexture.create_from_image(image)
	set_shader()
	await RenderingServer.frame_post_draw
	var my_texture = sub_viewport.get_texture()
	texture = my_texture


func _process(delta: float) -> void:
	#set_shader()
	pass	
	#await RenderingServer.frame_post_draw
	#var my_texture = sub_viewport.get_texture()
	
	
func set_shader() -> void:
	var global_points: Array[Vector2] = []
	# Get the baked points (local to the Path2D node)
	var local_points = path_2d.curve.get_baked_points()
	
	for local_point in local_points:
		# Convert each local point to global space, considering 
		# the Path2D's position, rotation, and scale
		var global_point =  path_2d.to_global(local_point)
		global_points.append(global_point)
	
	#Logging.logMessage("Length: " + str(path_2d.curve.get_baked_length()))
	#Logging.logMessage("Points: " + str(local_points.size()))
	
	var s : ShaderMaterial = path_sprite.material as ShaderMaterial
	s.set_shader_parameter("points", global_points)
	s.set_shader_parameter("pos", Vector2(0,0))
	s.set_shader_parameter("num_points", global_points.size())
