extends CharacterBody3D


const LAUNCH_FORCE = 0.5
const AIR_ROTATION_SPEED = 6
const ROTATION_AXIS = Vector3(0, 0, 1.0)
const BULLET_TIME_SLOW = 0.1
const BULLET_TIME_JUICE_DRAIN = 60
const JUICE_REGEN = 80
const CHARGE_SPEED = 80
const DASH_COST = 5
const LAUNCH_MAX_COOLDOWN = 0.6

const CHARGE_VECTOR_CONSTANT = 0.5
const MAX_CHARGE = 80
const MIN_CHARGE = 20

@onready var collision_shape = $CollisionShape3D
@onready var camera = $Camera3D
@onready var juice_bar = $Camera3D/Control/Node2D/JuiceBar

@onready var arrow_node = $ArrowNode
@onready var animator = $CollisionShape3D/cumber/AnimationPlayer

@onready var aoe_scene = preload("res://Player/cucumber_aoe.tscn")

const MAX_JUICE_POINTS = 100
var juice_points = MAX_JUICE_POINTS

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var charging_jump = false
var curr_charge_time = 0
var launch_cooldown = 0
var doing_aoe = false

var current_trail = Trail

func _ready():
	juice_bar.max_value = MAX_JUICE_POINTS


func _physics_process(delta):
	# Clamp juice
	juice_points = clamp(juice_points, 0, MAX_JUICE_POINTS)
	
	# Update juice bar
	update_juicebar()
	
	# Never move in z
	velocity.z = 0
	
	#Handle drawing arrow
	if(charging_jump):
		handle_arrow_animation()
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
		# Rotate when in the air (very funny and cool)
		do_rotation(delta)
	
	else:
		if doing_aoe:
			spawn_aoe()
			doing_aoe = false
		
		juice_points += JUICE_REGEN*delta
		
		# Stop if on floor
		velocity.x = 0
		velocity.y = 0
		

		# Stand upright if on foor
		var mouse_direction = get_mouse_pos_in_scene() - global_transform.origin
		if mouse_direction.x > 0:
			collision_shape.rotation = Vector3(0, -PI/2, 0)
		else:
			collision_shape.rotation = Vector3(0, PI/2, 0)

		if Input.is_action_pressed("launch") and curr_charge_time > 0:
			animator.play("ArmatureAction")
		
		if Input.is_action_just_released("launch"):
			animator.stop()
	
	if launch_cooldown >= 0:
		launch_cooldown -= delta
			
	# Check for launch input
	if Input.is_action_pressed("launch") and juice_points > 0 and launch_cooldown <= 0:
		if !charging_jump:
			charging_jump = true
			juice_points -= DASH_COST
			if not is_on_floor():
				Engine.time_scale = BULLET_TIME_SLOW
		var time_scale = Engine.time_scale
		juice_points -= BULLET_TIME_JUICE_DRAIN*delta/time_scale
		curr_charge_time += CHARGE_SPEED*delta/time_scale
		if curr_charge_time >= MAX_CHARGE:
			curr_charge_time = MAX_CHARGE

	if Input.is_action_just_released("launch") and curr_charge_time > 0:
		charging_jump = false
		arrow_node.visible = false
		Engine.time_scale = 1.0
		
		if not is_on_floor():
			doing_aoe = true
		
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
			velocity = saved_velocity.length()*0.8*bounce_direction

func handle_arrow_animation():
	arrow_node.visible = true
	var arrow = arrow_node.get_node("Arrow")
	var charge_percent = float(curr_charge_time)/float(MAX_CHARGE)
	var animation = arrow.get_node("AnimationPlayer")
	if(!animation.is_playing()):
		animation.play("arrow_longer")
	animation.seek(charge_percent,true,true)
	var player_pos = global_transform.origin
	var mouse_pos_3d = get_mouse_pos_in_scene()
	var launch_vector = (mouse_pos_3d - player_pos)
	arrow_node.look_at(mouse_pos_3d)

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
	if intersection == {}:
		return Vector3(0,0,0)
	
	return space_state.intersect_ray(query)["position"]
	
func launch(launch_direction):
	var curr_force = LAUNCH_FORCE * (curr_charge_time + MIN_CHARGE)
	velocity = curr_force * launch_direction.normalized()
	curr_charge_time = 0
	launch_cooldown = LAUNCH_MAX_COOLDOWN
	
func do_rotation(delta):
	# Rotate towards movement direction
	var air_rotation = AIR_ROTATION_SPEED
	if velocity.x > 0:
		air_rotation = -AIR_ROTATION_SPEED

	collision_shape.rotate(ROTATION_AXIS, air_rotation*delta)


func update_juicebar():
	juice_bar.value = juice_points


func add_juice(amount):
	juice_points += amount
	juice_points = clamp(juice_points, 0, MAX_JUICE_POINTS)

func spawn_aoe():
	var aoe_instance = aoe_scene.instantiate()
	aoe_instance.set_position(position)
	get_tree().get_root().add_child(aoe_instance)

func make_trail():
	current_trail = Trail.create()
	add_child(current_trail)
