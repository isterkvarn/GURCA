extends Area3D

const RESPAWN_TIMER = 5.0

@onready var mesh1 = $MeshInstance3D
@onready var mesh2 = $MeshInstance3D2

@export var juice_amount = 50
var active = true
var timer = 0.0

func _process(delta):
	timer += delta
	
	if timer > RESPAWN_TIMER:
		timer = 0.0
		active = true
		mesh1.visible = true
		mesh2.visible = true

func _on_body_entered(body):
	if body.is_in_group("Player") and active:
		body.add_juice(juice_amount)
		active = false
		mesh1.visible = false
		mesh2.visible = false
		
