extends CharacterBody3D


const LAUNCH_FORCE = 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Never move in z
	velocity.z = 0
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	else:
		# Stop if on floor
		velocity.x = 0
		velocity.y = 0
	
		# Check for launch input
		if Input.is_action_just_pressed("launch"):
			launch(Vector3(1, 1, 0))

	move_and_slide()
	
func launch(launch_direction):
	velocity += LAUNCH_FORCE * launch_direction.normalized()
