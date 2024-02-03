extends CharacterBody3D


const LAUNCH_FORCE = 0.5
const AIR_ROTATION_SPEED = 6
const ROTATION_AXIS = Vector3(0, 0, 1.0)
const BULLET_TIME_SLOW = 0.1

const MAX_CHARGE = 100


@onready var collision_shape = $CollisionShape3D
@onready var camera = $Camera3D

const MAX_JUICE_POINTS = 100
var juice_points = MAX_JUICE_POINTS

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var charging_jump = false
var curr_charge_time = 0

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
		if Input.is_action_pressed("launch"):
			if !charging_jump:
				charging_jump = true
				curr_charge_time = 0
			curr_charge_time += 1
			if curr_charge_time >= MAX_CHARGE:
				curr_charge_time = MAX_CHARGE
			
			
		
		if Input.is_action_just_released("launch"):
			charging_jump = false
			

			var player_pos = global_transform.origin
			var mouse_pos_3d = get_mouse_pos_in_scene()
			var launch_vector = (mouse_pos_3d - player_pos).normalized()
			launch(launch_vector)

	# Save velocity to use for bounce
	var saved_velocity = velocity

	move_and_slide()
	
	# If collision bounce of stuff, should be nullified if on floor
	if get_slide_collision_count():
		var collision = get_slide_collision(0)
		if collision: 
			var bounce_direction = collision.get_collider(0).global_position.direction_to(global_position)
			velocity = saved_velocity.length()*0.5*bounce_direction

func get_mouse_pos_in_scene():
	var ray_length = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_start = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_start + camera.project_ray_normal(mouse_pos) * ray_length
	var world3d : World3D = get_world_3d()
	var space_state = world3d.direct_space_state
	
	if space_state == null:
		return
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var intersection = space_state.intersect_ray(query)
	if intersection == null:
		return Vector3(0,0,0)
	
	return space_state.intersect_ray(query)["position"]
	
func launch(launch_direction):
	var curr_force = LAUNCH_FORCE  * curr_charge_time
	velocity += curr_force * launch_direction.normalized()
	
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
