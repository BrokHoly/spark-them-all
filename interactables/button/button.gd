extends Interactable

@onready var mesh: MeshInstance3D = $CollisionShape3D/MeshInstance3D
var material

@export var idle_color : Color
@export var focus_color : Color
@export var press_color : Color
@export var off_color : Color
@export var disable_color : Color

func _ready():
	material = mesh.get_active_material(0).duplicate()
	mesh.set_surface_override_material(0, material)
	_update_visual()


func _update_visual():
	if not enable:
		material.albedo_color = disable_color
	elif is_being_pressed:
		material.albedo_color = press_color
	elif is_pressed:
		material.albedo_color = off_color
	elif is_hovered:
		material.albedo_color = focus_color
	else:
		material.albedo_color = idle_color
