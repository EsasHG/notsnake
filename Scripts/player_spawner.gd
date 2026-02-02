extends Node2D

class_name PlayerSpawner

@export var spawn_on_start = true;
var playerID : int = -1
var player_scene: PackedScene = preload("uid://bkjd5mneny7c1")
@onready var spawn_timer : Timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if spawn_on_start:
		spawn_player()
	spawn_timer.wait_time = 3
	spawn_timer.autostart = false
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(spawn_player)
	add_child(spawn_timer)


func spawn_player() -> PlayerDog:
	if playerID > -1:
		var p : PlayerDog = player_scene.instantiate()
		p.playerControl = true
		p.playerID = playerID
		var hat_id = GlobalInputMap.Player_Hats_Selected[playerID]
		p.currentHat = hat_id
		get_parent().add_child.call_deferred(p)
		p.self_modulate = GlobalInputMap.player_colors[GlobalInputMap.Player_Color_Selected[playerID]]
		p.global_position = global_position
		return p
	else:
		return null
func start_timer() -> void:
	spawn_timer.start()

func stop_timer() -> void:
	spawn_timer.stop()
	
