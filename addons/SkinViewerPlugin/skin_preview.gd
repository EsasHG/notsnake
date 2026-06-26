@tool
extends VBoxContainer
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var camera_2d: Camera2D = $SubViewportContainer/SubViewport/Camera2D
@onready var head: AnimatedSprite2D = $SubViewportContainer/SubViewport/Dog/Head
@onready var legs: AnimatedSprite2D = $SubViewportContainer/SubViewport/Dog/Head/Legs
@onready var butt_sprite: Sprite2D = $SubViewportContainer/SubViewport/Dog/ButtSprite
@onready var tail: AnimatedSprite2D = $SubViewportContainer/SubViewport/Dog/ButtSprite/Tail
@onready var legs_back: AnimatedSprite2D = $SubViewportContainer/SubViewport/Dog/ButtSprite/Legs_back
@onready var body_segment: Sprite2D = $SubViewportContainer/SubViewport/Dog/BodySegment
@onready var hat: Sprite2D = $SubViewportContainer/SubViewport/Dog/Head/Hat
@onready var check_button: CheckButton = $CheckButton
var current_skin:DogSkin

func setup_preview(skin:DogSkin) -> void:
	if current_skin:
		current_skin.changed.disconnect(_update_viewport_render)
	current_skin = skin
	current_skin.changed.connect(_update_viewport_render)

	_update_viewport_render.call_deferred()
	

func _update_viewport_render() -> void:
	if not current_skin:
		return
	hat.visible = check_button.button_pressed
	head.sprite_frames = current_skin.head
	butt_sprite.texture = current_skin.butt
	butt_sprite.position = current_skin.butt_offset
	legs.sprite_frames = current_skin.legs_front
	legs.position = current_skin.legs_front_offset
	legs_back.sprite_frames = current_skin.legs_back
	legs_back.position = current_skin.legs_back_offset
	tail.sprite_frames = current_skin.tail
	tail.position = current_skin.tail_offset
	body_segment.texture = current_skin.body_segment
	body_segment.position = current_skin.body_offset
	hat.position = Vector2(0,-12.5) + current_skin.hat_offset
	head.modulate = current_skin.modulate
	butt_sprite.modulate = current_skin.modulate
	body_segment.modulate = current_skin.modulate
	legs.play()
	legs_back.play()
	tail.play()
		


func _on_check_button_toggled(toggled_on: bool) -> void:
	hat.visible = toggled_on
