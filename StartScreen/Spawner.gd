extends Node3D

const Y_POS = 40.0

const MIN_Z_POS = -50.0
const MAX_Z_POS = -25.0

const MIN_X_POS = -50.0
const MAX_X_POS = 50.0

const VEL_MIN = -25.0
const VEL_MAX = 25.0

@onready var zombie_scene = preload("res://Zombie/zombie.tscn")
var zombies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if randf() < 0.01:
		spawn_zombie()


func spawn_zombie():
	var zombie = zombie_scene.instantiate()
	
	zombie.position.x = randi_range(MIN_X_POS, MAX_X_POS)
	zombie.position.y = Y_POS
	zombie.position.z = randi_range(MIN_Z_POS, MAX_Z_POS)
	
	zombies.append(zombie)
	add_child(zombie)
	
	zombie.take_attack(Vector3(
		randi_range(VEL_MIN, VEL_MAX),
		randi_range(VEL_MIN, VEL_MAX),
		0
	))
