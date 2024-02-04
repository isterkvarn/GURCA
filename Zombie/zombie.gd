extends CharacterBody3D

const SPEED = 300.0
const JUMP_VELOCITY = 4.5
const DIR_CHANGE_DELAY = 0.5
# The Y-level where the zombies should be deallocated
const Y_DEALLOCATE = -30.0

const RANDOM_ROT_MIN = 0.5
const RANDOM_ROT_MAX = 3.0

enum DIR {LEFT = -1, RIGHT = 1}
enum MODE {NORMAL, ATTACKED}

@onready var mode = MODE.NORMAL
@onready var dir = DIR.RIGHT
@onready var ray_right = $"Rays/RayRight"
@onready var ray_left = $"Rays/RayLeft"
@onready var model = $"Zombie"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var last_pos = null
var dir_change_delay = 0.0
var rot: Vector3


func _ready():
	dir = (randi() % 2) * 2 - 1
	set_model_rotation()


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if mode == MODE.NORMAL:
		handle_collision(delta)
	elif mode == MODE.ATTACKED:
		if position.y < Y_DEALLOCATE:
			queue_free()
		model.rotation.x += delta * rot.x
		model.rotation.y += delta * rot.y
		model.rotation.z += delta * rot.z
	
	move_and_slide()


func set_random_rotation():
	rot = Vector3(
		randf() * (RANDOM_ROT_MAX - RANDOM_ROT_MIN) + RANDOM_ROT_MIN,
		randf() * (RANDOM_ROT_MAX - RANDOM_ROT_MIN) + RANDOM_ROT_MIN,
		randf() * (RANDOM_ROT_MAX - RANDOM_ROT_MIN) + RANDOM_ROT_MIN
	)


func set_model_rotation():
	model.rotation.y = PI/2 * dir


func handle_collision(delta):
	if is_on_floor():
		velocity.x = SPEED * delta * dir

	# Check if its up against a wall
	if is_stuck(delta) and dir_change_delay == 0:
		dir = (dir + 3) % 4 - 1
		dir_change_delay += delta
		set_model_rotation()
	
	# Check if its about to walk off a ledge
	if is_on_floor() and dir_change_delay == 0:
		if not ray_right.is_colliding():
			dir = DIR.LEFT
			set_model_rotation()
		elif not ray_left.is_colliding():
			dir = DIR.RIGHT
			set_model_rotation()
		
	if dir_change_delay != 0:
		dir_change_delay += delta
	if dir_change_delay > DIR_CHANGE_DELAY:
		dir_change_delay = 0
		
	last_pos = position


func is_stuck(delta) -> bool:
	if last_pos == null:
		return false

	return abs(position.x - last_pos.x) < 0.001


func take_attack(dir: Vector3):
	velocity.x += dir.x
	velocity.y += dir.y
	velocity.z += dir.z
	
	model.rotation.y = 0
	set_random_rotation()
	mode = MODE.ATTACKED
