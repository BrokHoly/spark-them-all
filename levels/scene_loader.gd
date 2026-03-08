extends Node

signal progress_changed(progress)
signal load_finished

var loading_screen: PackedScene = preload("uid://evrmwxa4c86v")
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = true

func _ready() -> void:
	set_process(false)


func load_scene(_scene_path: String) -> void : 
	scene_path = _scene_path
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
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_changed.emit(progress[0])
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			set_process(false)
			# Save current player state
			var player = get_tree().get_first_node_in_group("player")
			if player:
				Game.player_stats = player.stats
				Game.player_health = player.health
				Game.grapes = player.boular_grapes
				Game.kills = player.kill_score
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			# Change scene
			get_tree().change_scene_to_packed(loaded_resource)
			await get_tree().scene_changed
			# Spawn new player
			var new_player = Game.player_scene.instantiate()
			if Game.player_stats != null:
				new_player.stats = Game.player_stats
			else:
				new_player.stats = Stats.new()

			new_player.health = Game.player_health
			new_player.boular_grapes = Game.grapes
			new_player.kill_score = Game.kills

			get_tree().current_scene.add_child(new_player)
			var spawn = get_tree().current_scene.get_node_or_null("PlayerSpawn")
			if spawn:
				new_player.global_transform = spawn.global_transform
			load_finished.emit()
