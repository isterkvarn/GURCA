extends Node3D


@onready var map_scene = preload("res://Maps/map.tscn")

var active = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if event is InputEventKey:
		var key_event = event as InputEventKey
		if key_event.keycode == 88 and not key_event.pressed:
			active = not active
			return
		elif key_event.keycode == 88:
			return

	if not event is InputEventMouseMotion and active:
		get_tree().root.add_child(map_scene.instantiate())
		get_node("/root/Start").free()
