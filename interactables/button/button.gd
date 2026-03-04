extends Interactable

@onready var mesh: MeshInstance3D = $CollisionShape3D/MeshInstance3D
var material

func _ready():
	material = mesh.get_active_material(0).duplicate()
	mesh.set_surface_override_material(0, material)
	_update_visual()


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
