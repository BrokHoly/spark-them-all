extends Node3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var mesh_mirrored: MeshInstance3D = $MeshInstance3DMirorred
@onready var collision_shape: CollisionShape3D = $StaticBody3D/CollisionShape3D

const SIZE = 1000
const RESOLUTION = 100
const HEIGHT_SCALE = 5.0
const FLAT_RADIUS = 50.0        # radius around origin that stays flat
const CEILING_HEIGHT = 75.0     # vertical offset of the ceiling mesh

var noise := FastNoiseLite.new()

func _ready():
	noise.seed = randi()
	noise.frequency = 0.05
	generate_terrain()

func generate_terrain():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var step = float(SIZE) / float(RESOLUTION)
	var half = SIZE / 2.0

	for i in range(RESOLUTION):
		for j in range(RESOLUTION):
			var x = -half + i * step
			var z = -half + j * step
			add_quad(st, x, z, step)

	st.generate_normals()
	var mesh = st.commit()
	mesh_instance.mesh = mesh

	# Mirrored ceiling
	var st_mirror = SurfaceTool.new()
	st_mirror.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in range(RESOLUTION):
		for j in range(RESOLUTION):
			var x = -half + i * step
			var z = -half + j * step
			add_quad_flipped(st_mirror, x, z, step)

	st_mirror.generate_normals()
	mesh_mirrored.mesh = st_mirror.commit()
	mesh_mirrored.translate(Vector3(0.0, CEILING_HEIGHT, 0.0))

	var shape = mesh.create_trimesh_shape()
	collision_shape.shape = shape

	_generate_walls()

func get_height(x: float, z: float) -> float:
	var dist = Vector2(x, z).length()
	if dist < FLAT_RADIUS:
		return 0.0
	var height = noise.get_noise_2d(x, z)
	if height >= 0.45:
		return 100.0
	return height * HEIGHT_SCALE

func _generate_walls():
	var half = SIZE / 2.0
	var wall_height = CEILING_HEIGHT*2

	# Four edges: -X, +X, -Z, +Z
	var walls = [
		{"from": Vector3(-half, 0, -half), "to": Vector3(-half, 0,  half), "normal": Vector3( 1, 0, 0)},
		{"from": Vector3( half, 0,  half), "to": Vector3( half, 0, -half), "normal": Vector3(-1, 0, 0)},
		{"from": Vector3( half, 0, -half), "to": Vector3(-half, 0, -half), "normal": Vector3( 0, 0, 1)},
		{"from": Vector3(-half, 0,  half), "to": Vector3( half, 0,  half), "normal": Vector3( 0, 0,-1)},
	]

	for wall in walls:
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)

		var a = wall["from"]
		var b = wall["to"]

		var v00 = Vector3(a.x, 0,           a.z)
		var v10 = Vector3(b.x, 0,           b.z)
		var v01 = Vector3(a.x, wall_height, a.z)
		var v11 = Vector3(b.x, wall_height, b.z)

		st.add_vertex(v00); st.add_vertex(v10); st.add_vertex(v11)
		st.add_vertex(v00); st.add_vertex(v11); st.add_vertex(v01)

		st.generate_normals()
		var wall_mesh_instance = MeshInstance3D.new()
		wall_mesh_instance.mesh = st.commit()
		add_child(wall_mesh_instance)

		# Collision for wall
		var static_body = StaticBody3D.new()
		var col = CollisionShape3D.new()
		var box = BoxShape3D.new()
		# Thin box along the wall
		var is_x_wall = (a.x == b.x)
		if is_x_wall:
			box.size = Vector3(1.0, wall_height, SIZE)
			static_body.position = Vector3(a.x, wall_height * 0.5, 0)
		else:
			box.size = Vector3(SIZE, wall_height, 1.0)
			static_body.position = Vector3(0, wall_height * 0.5, a.z)
		col.shape = box
		static_body.add_child(col)
		add_child(static_body)

func add_quad_flipped(st: SurfaceTool, x: float, z: float, step: float):
	var x0 = x; var x1 = x + step
	var z0 = z; var z1 = z + step

	var v00 = Vector3(x0, -get_height(x0, z0), z0)
	var v10 = Vector3(x1, -get_height(x1, z0), z0)
	var v01 = Vector3(x0, -get_height(x0, z1), z1)
	var v11 = Vector3(x1, -get_height(x1, z1), z1)

	st.add_vertex(v00); st.add_vertex(v11); st.add_vertex(v10)
	st.add_vertex(v00); st.add_vertex(v01); st.add_vertex(v11)

func add_quad(st: SurfaceTool, x: float, z: float, step: float):
	var x0 = x; var x1 = x + step
	var z0 = z; var z1 = z + step

	var v00 = Vector3(x0, get_height(x0, z0), z0)
	var v10 = Vector3(x1, get_height(x1, z0), z0)
	var v01 = Vector3(x0, get_height(x0, z1), z1)
	var v11 = Vector3(x1, get_height(x1, z1), z1)

	st.add_vertex(v00); st.add_vertex(v10); st.add_vertex(v11)
	st.add_vertex(v00); st.add_vertex(v11); st.add_vertex(v01)
