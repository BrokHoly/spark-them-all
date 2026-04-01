extends Node

signal progress_changed(progress)
signal load_finished

const PLAYER_SCENE_UID = "uid://crhr55ln80al5"

var loading_screen: PackedScene = preload("uid://evrmwxa4c86v")
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = false

func _ready() -> void:
	set_process(false)


func load_scene(_scene_path: String) -> void:
	if _scene_path == "" or _scene_path == null:
		push_error("Scene path is empty!")
		return

	scene_path = _scene_path
	print("LOADING SCENE:", scene_path)

	var new_load_screen = loading_screen.instantiate()
	add_child(new_load_screen)
	progress_changed.connect(new_load_screen._on_progress_changed)
	load_finished.connect(new_load_screen._on_load_finished)
	await new_load_screen.loading_screen_read
	start_load()


func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)


func _process(_delta: float) -> void:
	if scene_path == "" or scene_path == null:
		return

	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_changed.emit(progress[0])

	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Failed to load scene: " + scene_path)
			set_process(false)

		ResourceLoader.THREAD_LOAD_LOADED:
			set_process(false)

			# Save current player state
			var player = get_tree().get_first_node_in_group("player")
			if player:
				var s = player.stats
				# Just reset run_kills, everything else is already correct
				s.set_base("run_kills", 0.0)
				s.set_flat("run_kills", 0.0)
				Game.player_stats = s.copy()
				Game.player_health = player.health

			# Load new scene
			var res = ResourceLoader.load_threaded_get(scene_path)
			if res == null:
				push_error("Loaded resource is null for: " + scene_path)
				return
			if not res is PackedScene:
				push_error("Resource is not a PackedScene: " + scene_path)
				return

			loaded_resource = res
			get_tree().change_scene_to_packed(loaded_resource)
			await get_tree().scene_changed

			# Load player fresh every time to avoid resource cache corruption
			var player_scene: PackedScene = load(PLAYER_SCENE_UID)
			if player_scene == null:
				push_error("Player scene failed to load!")
				return
			print("Node count: ", player_scene.get_state().get_node_count())

			var new_player = player_scene.instantiate()
			if new_player == null:
				push_error("Failed to instantiate player scene!")
				return

			# Restore stats
			if Game.player_stats != null:
				new_player.stats = Game.player_stats.copy()
			else:
				new_player.stats = Stats.new()

			new_player.health = Game.player_health

			# Add player to new scene
			get_tree().current_scene.add_child(new_player)
			new_player.add_to_group("player")
			new_player.owner = get_tree().current_scene

			# Move to spawn point if one exists
			var spawn = get_tree().current_scene.get_node_or_null("PlayerSpawn")
			if spawn:
				new_player.global_transform = spawn.global_transform

			load_finished.emit()
