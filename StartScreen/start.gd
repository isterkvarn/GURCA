extends Node3D


@onready var map_scene = preload("res://Maps/map.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if not event is InputEventMouseMotion:
		get_tree().root.add_child(map_scene.instantiate())
		get_node("/root/Start").free()
