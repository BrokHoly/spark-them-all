extends Node

var level_scene: PackedScene = preload("res://levels/cave_level.tscn")

func load_level(level: int):

	var level_instance = level_scene.instantiate()
	level_instance.cave_level = level

	get_tree().root.add_child(level_instance)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = level_instance
