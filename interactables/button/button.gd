extends Interactable

@export var target_node: Affected   # Something to affect in the world. Nothing for now

@onready var mesh: MeshInstance3D = $CollisionShape3D/MeshInstance3D
var material

func _ready():
	material = mesh.get_active_material(0).duplicate()
	mesh.set_surface_override_material(0, material)
	_update_visual()


func interact(player):
	if toggle_mode:
		is_pressed = !is_pressed
	else:
		is_pressed = true
	_update_visual()
	_trigger_target()

func _update_visual():
	if not enable:
		material.albedo_color = Color.DARK_GRAY
	elif is_being_pressed:
		material.albedo_color = Color.BLUE
	elif is_pressed:
		material.albedo_color = Color.RED
	elif is_hovered:
		material.albedo_color = Color.YELLOW
	else:
		material.albedo_color = Color.GREEN

func _trigger_target():
	if target_node:
		target_node.affect(is_pressed)
