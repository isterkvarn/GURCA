extends Area3D

const MAX_ANGLE = 45.0
const SPEED = 10.0

@onready var shape = $"CollisionShape3D"
@onready var width = shape.shape.extents.x


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if not body.is_in_group("zombie"):
		return
	
	# Position of zombie relative to the aoe, normalized between -1 - 1
	var zombie_pos = (position.x - body.get_position().x) / width
	var angle = deg_to_rad(MAX_ANGLE * zombie_pos)

	var dir = Vector3(sin(angle + PI) * SPEED, cos(angle) * SPEED, 0)

	body.take_attack(dir)
