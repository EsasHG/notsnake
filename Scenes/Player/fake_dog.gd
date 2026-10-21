extends Node2D
var segment = preload("uid://c84i47m2lf0ea")

@export var segment_rot:float = 4.8
@export var rot_speed = -160
@export var rotate_dog : bool = false

@onready var butt_sprite: Sprite2D = $ButtSprite
@onready var head: AnimatedSprite2D = $Head
@onready var legs: AnimatedSprite2D = $Head/Legs
@onready var legs_back: AnimatedSprite2D = $ButtSprite/Legs_back
@onready var tail: AnimatedSprite2D = $ButtSprite/Tail
@onready var hat: Sprite2D = $Head/Hat
var segments: Array[Sprite2D]
func _ready() -> void:
	GameSettings.on_dogSkinChanged.connect(set_skin)
	GameSettings.on_dogHatChanged.connect(set_hat)
	head.play("default")
	legs.play("default")
	legs_back.play("default")
	for i in 20:
		print("adding sprite")
		var sprite_holder = Node2D.new()
		sprite_holder.global_rotation = deg_to_rad(segment_rot)*i
		add_child(sprite_holder)
		
		var sprite = Sprite2D.new()
		sprite.texture = segment
		sprite.position.x = -60
		sprite_holder.add_child.call_deferred(sprite)
		segments.append(sprite)
	var node = Node2D.new()
	node.global_rotation = deg_to_rad(segment_rot)*20
	add_child(node)

	butt_sprite.reparent.call_deferred(node,false)
	
func _process(delta: float) -> void:
	if rotate_dog:
		rotate(deg_to_rad(rot_speed*delta))
	

func set_skin(dog_id:String, skin_id:String) -> void:
	if not GlobalInputMap.dogs.has(dog_id):
		Logging.error("Could not find dog with ID " + dog_id)
		dog_id = "DEFAULT"
	if not GlobalInputMap.dogs[dog_id].has(skin_id):
		Logging.error("Could not find skin with ID " + skin_id + " for dog " + dog_id)
		skin_id = "DEFAULT"
	var skin:DogSkin = GlobalInputMap.dogs[dog_id][skin_id]
	self_modulate = skin.modulate
	head.sprite_frames = skin.head
	head.self_modulate = self_modulate
	legs.sprite_frames = skin.legs_front
	legs.modulate = skin.modulate
	legs_back.sprite_frames = skin.legs_back
	butt_sprite.texture = skin.butt
	tail.sprite_frames = skin.tail
	legs.play("default")
	legs_back.play("default")
	tail.play("default")
	segment = skin.body_segment
	modulate = skin.modulate
	hat.position = GlobalInputMap.hats[GlobalInputMap.hats_selected[0]].offset + skin.hat_offset
	for seg in segments:
		seg.texture = segment

func set_hat(hat_id:String):
	var new_hat =  GlobalInputMap.hats[hat_id]

	hat.texture = new_hat.texture
	hat.position = new_hat.offset + GlobalInputMap.dogs[GlobalInputMap.dogs_selected[0]][GlobalInputMap.skins_selected[0]].hat_offset
