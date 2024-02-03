extends CharacterBody3D

const SPEED = 100.0
const JUMP_VELOCITY = 4.5
const DIR_CHANGE_DELAY = 0.5

enum DIR {LEFT = -1, RIGHT = 1}

@onready var dir = DIR.RIGHT
@onready var ray_right = $"Rays/RayRight"
@onready var ray_left = $"Rays/RayLeft"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var last_pos = null
var dir_change_delay = 0.0

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	velocity.x = SPEED * delta * dir

	handle_collision(delta)
	
	move_and_slide()


func handle_collision(delta):
	# Check if its up against a wall
	if is_stuck(delta) and dir_change_delay == 0:
		dir = (dir + 3) % 4 - 1
		dir_change_delay += delta
	
	# Check if its about to walk off a ledge
	if is_on_floor() and dir_change_delay == 0:
		if not ray_right.is_colliding():
			dir = DIR.LEFT
		elif not ray_left.is_colliding():
			dir = DIR.RIGHT
		
	if dir_change_delay != 0:
		dir_change_delay += delta
	if dir_change_delay > DIR_CHANGE_DELAY:
		dir_change_delay = 0
		
	last_pos = position



func is_stuck(delta) -> bool:
	if last_pos == null:
		return false

	return abs(position.x - last_pos.x) < 0.001
