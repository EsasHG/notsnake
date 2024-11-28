extends Node2D
class_name PickupSpawner
@export var xBorder : int = 800
@export var yBorder : int = 400

@onready var toy = preload("res://Scenes/DogToy.tscn")
@onready var bone = preload("res://Scenes/DogBone.tscn")
@onready var pickupPoints : Array[Node] = get_tree().root.find_child("PickupPoints", true, false).get_children()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SpawnPickup()
	

func SpawnPickup():
	var boneOrToy = randi_range(0,1)
	var pickup : Area2D
	if(boneOrToy):
		pickup = bone.instantiate()
	else:
		pickup = toy.instantiate()
	
	
	var point : int = randi_range(0, pickupPoints.size()-1)
	
	#var pickupLoc : Vector2 = Vector2(randi_range(-xBorder, xBorder), randi_range(-yBorder, yBorder))
	pickup.position = pickupPoints[point].position
	
	
	#while pickup.has_overlapping_areas():
	#	pickupLoc = Vector2(randi_range(-xBorder, xBorder), randi_range(-yBorder, yBorder))
	#	pickup.position = pickupLoc
		
	#pickup.position = pickupLoc
	
	print_debug("Adding pickup")
	
	add_child.call_deferred(pickup)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
