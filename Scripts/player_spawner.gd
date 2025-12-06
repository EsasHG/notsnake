extends Node2D

var player: PackedScene = preload("uid://bkjd5mneny7c1")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var p : PlayerDog = player.instantiate()
	p.playerControl = true
	get_parent().add_child.call_deferred(p)
	p.global_position = global_position
