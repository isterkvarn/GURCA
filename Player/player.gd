extends CharacterBody3D


const LAUNCH_FORCE = 35
const AIR_ROTATION_SPEED = 6
const ROTATION_AXIS = Vector3(0, 0, 1.0)
const BULLET_TIME_SLOW = 0.1

@onready var collision_shape = $CollisionShape3D

const MAX_JUICE_POINTS = 100
var juice_points = MAX_JUICE_POINTS

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	
	check_bullet_time()
	
	# Never move in z
	velocity.z = 0
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
		# Rotate when in the air (very funny and cool)
		do_rotation(delta)
	
	else:
		# Stop if on floor
		velocity.x = 0
		velocity.y = 0
		
		# Stand upright if on foor
		collision_shape.rotation = Vector3.ZERO
	
		# Check for launch input
		if Input.is_action_just_pressed("launch"):
			launch(Vector3(1, 1, 0))

	# Save velocity to use for bounce
	var saved_velocity = velocity

	move_and_slide()
	
	# If collision bounce of stuff, should be nullified if on floor
	if get_slide_collision_count():
		var collision = get_slide_collision(0)
		if collision: 
			var bounce_direction = collision.get_collider(0).global_position.direction_to(global_position)
			velocity = saved_velocity.length()*0.5*bounce_direction

	
func launch(launch_direction):
	velocity += LAUNCH_FORCE * launch_direction.normalized()
	
func do_rotation(delta):
	# Rotate towards movement direction
	var air_rotation = AIR_ROTATION_SPEED
	if velocity.x > 0:
		air_rotation = -AIR_ROTATION_SPEED

	collision_shape.rotate(ROTATION_AXIS, air_rotation*delta)

func check_bullet_time():
	if Input.is_action_pressed("bullet_time"):
		Engine.time_scale = BULLET_TIME_SLOW
	else:
		Engine.time_scale = 1.0
