extends Node

var player_scene: PackedScene = preload("res://characters/player/player.tscn")

var player_stats: Stats
var player_health: float
var grapes := 0
var kills := 0

var cave_level : int = 1
