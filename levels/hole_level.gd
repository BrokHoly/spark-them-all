# Area3D loader
extends Area3D

@export var next_scene_path: String
var loading := false

func _ready():
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
	if status != ResourceLoader.THREAD_LOAD_LOADED:
		return

	var packed_scene = ResourceLoader.load_threaded_get(next_scene_path)
	var new_scene = packed_scene.instantiate()

	# Move persistent Player
	var player = get_tree().get_root().get_node_or_null("Player")
	if player:
		if player.get_parent():
			player.get_parent().remove_child(player)
		new_scene.add_child(player)
		player.owner = new_scene

	# Replace current scene completely
	var old_scene = get_tree().current_scene
	get_tree().current_scene = new_scene
	if old_scene:
		old_scene.queue_free()
	get_tree().root.add_child(new_scene)

	loading = false
