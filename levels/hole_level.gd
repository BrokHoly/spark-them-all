extends Area3D

@export var next_scene_path: String
var loading := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if loading:
		return
		
	if body is Player:
		loading = true
		print("Preloading next scene...")
		ResourceLoader.load_threaded_request(next_scene_path)

func _process(_delta: float) -> void:
	if not loading:
		return
		
	var status = ResourceLoader.load_threaded_get_status(next_scene_path)
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		print("Scene ready. Switching.")
		var packed_scene = ResourceLoader.load_threaded_get(next_scene_path)
		get_tree().change_scene_to_packed(packed_scene)
