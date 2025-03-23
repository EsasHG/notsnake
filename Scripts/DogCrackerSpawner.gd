extends Node2D
class_name PickupSpawner

@onready var toy = preload("res://Scenes/DogToy.tscn")
@onready var bone = preload("res://Scenes/DogBone.tscn")
@onready var present = preload("res://Scenes/present.tscn")
@onready var pickupPoints : Array[Node] = $PickupPoints.get_children()
var prevPoint : int = 14
var currentPickup:Area2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.on_pickup.connect(SpawnPickup)
	
	SignalManager.on_gameBegin.connect(SpawnPickup)
	
	SignalManager.on_gameOver.connect(func(_won:bool): 	
		currentPickup.queue_free()
		prevPoint = -1
		)

func SpawnPickup():
	if(GameSettings.currentScore == 10):
		SpawnPresent()
		return
		
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
	currentPickup = pickup
	SignalManager.on_pickupSpawned.emit(pickup)
	
func SpawnPresent():
	
	var pickup : Area2D = present.instantiate()
	
	var point : int = prevPoint
	while point == prevPoint:
		point =	randi_range(0, pickupPoints.size()-1)
	prevPoint = point
	#var pickupLoc : Vector2 = Vector2(randi_range(-xBorder, xBorder), randi_range(-yBorder, yBorder))
	pickup.position = pickupPoints[point].position
	
	print_debug("Adding pickup")
	add_child.call_deferred(pickup)
	currentPickup = pickup
	SignalManager.on_pickupSpawned.emit(pickup)
	
	#while pickup.has_overlapping_areas():
	#	pickupLoc = Vector2(randi_range(-xBorder, xBorder), randi_range(-yBorder, yBorder))
	#	pickup.position = pickupLoc
		
	#pickup.position = pickupLoc
	

	
