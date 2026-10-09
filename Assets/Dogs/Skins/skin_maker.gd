@tool
extends EditorScript
const BASE_DIR = "res://Assets/Dogs/Skins/skins_colorChanges/"

const DEFAULT = preload("uid://cax0llp5vepyb")
func _run() -> void:

	print("Running skin_maker.gd...")
	var dirs = DirAccess.get_directories_at(BASE_DIR)
	for dir in dirs:
		if dir == "SKINS_MENU_icons":
			continue
		var full_path = BASE_DIR + "/" + dir + "/"
		var file_name = dir+ ".tres"
		
		if not FileAccess.file_exists(full_path + file_name):
			print("Creating skin ", file_name)
			var s = DogSkin.new()
			s.copy_from_resource(DEFAULT)
			s.butt = load(full_path + "BUTT_C_" + dir.to_upper() + ".png")
			s.body_segment = load(full_path + "BODY_SEGMENT_C_" + dir.to_upper() + ".png")
			s.head = _create_sprite_frames(full_path + "FACES_C_" + dir.to_upper() + ".png", 2)
			s.legs_back = _create_sprite_frames(full_path + "newdog_LegsBACK_sheet_C_" + dir.to_upper() + ".png", 5)
			s.legs_back.set_animation_speed("default", 10)
			s.legs_front = _create_sprite_frames(full_path + "newdog_LegsFRONT_sheet_C_" + dir.to_upper() + ".png", 5)
			s.legs_front.set_animation_speed("default", 10)
			s.tail = _create_sprite_frames(full_path + "TAIL_C_" + dir.to_upper() + ".png",1)
			s.unlocked = false
			s.icon = load("res://Assets/Dogs/Skins/skins_colorChanges/SKINS_MENU_icons/menuicon_"+ dir + ".png")
			s.price = 10
			var error = ResourceSaver.save(s, full_path + file_name)
			if error == OK:
				print("Resource saved successfully!")
			else:
				print("An error occurred while saving: ", error)

func _create_sprite_frames(file_name:String, num_frames:int) -> SpriteFrames:
	var full_head_tex :Texture2D = load(file_name)
	var head_frames :SpriteFrames = SpriteFrames.new()
	head_frames.add_animation("default")
	var head_frame_count = num_frames
	for i in head_frame_count:
		var frame_atlas = AtlasTexture.new()
		frame_atlas.atlas = full_head_tex
		frame_atlas.region = Rect2(
			Vector2(i*(full_head_tex.get_width()/head_frame_count), 0),
			Vector2(full_head_tex.get_width()/head_frame_count,full_head_tex.get_height())
		)
		head_frames.add_frame("default", frame_atlas)
	return head_frames
