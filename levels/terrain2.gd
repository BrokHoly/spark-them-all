extends MeshInstance3D

@onready var colShape = $StaticBody3D/CollisionShape3D
@onready var heightRatio = 0.25
var noise_threshold = 0.94

var img = Image.new()
var shape = HeightMapShape3D.new()

func _ready():
	#var img = Image.new()
	#img.load("res://levels/heightmaps/level1_map.exr")
	#img.convert(Image.FORMAT_RF)
#
	#var data = img.get_data().to_float32_array()
#
	## Apply your terrain logic
	#for i in range(data.size()):
		#if data[i] > noise_threshold:
			#data[i] *= 50.0
		#else:
			#data[i] *= heightRatio
#
	### --- COLLISION ---
	#var shape = HeightMapShape3D.new()
	#shape.map_width = img.get_width()
	#shape.map_depth = img.get_height()
	#shape.map_data = data
#
	#ResourceSaver.save(shape, "res://levels/heightmaps/level1_shape.res")
#
	### --- MESH ---
	#var mesh = generate_mesh(data, img.get_width(), img.get_height())
	#var cell_mesh = generate_ceiling_mesh(data, img.get_width(), img.get_height())
	#ResourceSaver.save(mesh, "res://levels/heightmaps/level1_mesh.res")
	#ResourceSaver.save(cell_mesh, "res://levels/heightmaps/level1_cell_mesh.res")
#
	#print("Terrain baked ✅")
	pass


func generate_mesh(data: PackedFloat32Array, width: int, depth: int) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for z in range(depth - 1):
		for x in range(width - 1):
			var i = z * width + x

			var v0 = Vector3(x, data[i], z)
			var v1 = Vector3(x + 1, data[i + 1], z)
			var v2 = Vector3(x, data[i + width], z + 1)
			var v3 = Vector3(x + 1, data[i + width + 1], z + 1)

			# Triangle 1
			st.add_vertex(v0)
			st.add_vertex(v1)
			st.add_vertex(v2)

			# Triangle 2
			st.add_vertex(v1)
			st.add_vertex(v3)
			st.add_vertex(v2)

	# 🔥 Génère les normales automatiquement
	st.generate_normals()

	return st.commit()


func generate_ceiling_mesh(data: PackedFloat32Array, width: int, depth: int) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var ceiling_height = 50.0

	for z in range(depth - 1):
		for x in range(width - 1):
			var i = z * width + x

			var v0 = Vector3(x, ceiling_height - data[i], z)
			var v1 = Vector3(x + 1, ceiling_height - data[i + 1], z)
			var v2 = Vector3(x, ceiling_height - data[i + width], z + 1)
			var v3 = Vector3(x + 1, ceiling_height - data[i + width + 1], z + 1)

			# 🔥 Correct inverted winding
			st.add_vertex(v0)
			st.add_vertex(v2)
			st.add_vertex(v1)

			st.add_vertex(v1)
			st.add_vertex(v2)
			st.add_vertex(v3)

	st.generate_normals()

	return st.commit()
