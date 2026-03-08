extends Node3D

@onready var label: Label3D = $Label3D

var lifetime := 1.0
var speed := 1.5

func setup(value: float):
	label.text = str(value)

func _process(delta):
	global_position.y += speed * delta
	lifetime -= delta
	label.modulate.a = lifetime
	if lifetime <= 0:
		queue_free()
