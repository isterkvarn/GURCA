extends Node3D

@onready var checkpoints = get_children()
@onready var player = %"Player"

var player_pos

func please_save_player():
	player_pos = player.get_position()

func please_restore_player():
	player.set_position(player_pos)
	player.set_velocity(Vector3(0, 0, 0))
