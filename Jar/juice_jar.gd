extends Area3D

@export var juice_amount = 50

func _on_body_entered(body):
	if body.is_in_group("Player"):
		print("juice")
		body.add_juice(juice_amount)
		queue_free()
