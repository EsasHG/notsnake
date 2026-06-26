@tool
extends Resource
class_name  DogSkin

@export_group("Sprites")
@export var head:SpriteFrames:
	set(value): 
		head = value
		changed.emit()
@export var legs_front:SpriteFrames:
	set(value): 
		legs_front = value
		changed.emit()
@export var legs_back:SpriteFrames:
	set(value): 
		legs_back = value
		changed.emit()
@export var butt:Texture2D:
	set(value): 
		butt = value
		changed.emit()
@export var tail:SpriteFrames:
	set(value): 
		tail = value
		changed.emit()
@export var body_segment:Texture2D:
	set(value): 
		body_segment = value
		changed.emit()
		
@export_group("Offsets")
@export var legs_front_offset: Vector2:
	set(value):
		legs_front_offset = value
		changed.emit()
		
@export var legs_back_offset: Vector2:
	set(value):
		legs_back_offset = value
		changed.emit()

@export var body_offset: Vector2:
	set(value):
		body_offset = value
		changed.emit()

@export var butt_offset: Vector2:
	set(value):
		butt_offset = value
		changed.emit()
		
@export var tail_offset: Vector2:
	set(value):
		tail_offset = value
		changed.emit()
@export var hat_offset: Vector2 = Vector2(0,0):
	set(value):
		hat_offset = value
		changed.emit()
@export_group("")
@export var modulate: Color = Color.WHITE:
	set(value):
		modulate = value
		changed.emit()
		
@export var price: int = 0
@export var unlocked: bool = false
