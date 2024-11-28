extends Node2D
class_name PickupSpawner

@onready var toy = preload("res://Scenes/DogToy.tscn")
@onready var bone = preload("res://Scenes/DogBone.tscn")
@onready var pickupPoints : Array[Node] = get_tree().root.find_child("PickupPoints", true, false).get_children()

var prevPoint : int = 14

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
	
	
	var point : int = prevPoint
	while point == prevPoint:
		point =	randi_range(0, pickupPoints.size()-1)
	prevPoint = point
	#var pickupLoc : Vector2 = Vector2(randi_range(-xBorder, xBorder), randi_range(-yBorder, yBorder))
	pickup.position = pickupPoints[point].position
	
	print_debug("Adding pickup")
	add_child.call_deferred(pickup)
	
	#while pickup.has_overlapping_areas():
	#	pickupLoc = Vector2(randi_range(-xBorder, xBorder), randi_range(-yBorder, yBorder))
	#	pickup.position = pickupLoc
		
	#pickup.position = pickupLoc
	

	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
