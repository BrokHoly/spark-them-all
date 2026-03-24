extends Node

var player_scene: PackedScene = preload("res://characters/player/player.tscn")

var player_stats: Stats
var player_health: float
var grapes := 0
var kills := 0

var cave_level : int = 1

var lamp_range_upgrade : int= 5
var collect_range_upgrade : int= 5
var lamp_damage_upgrade : int= 5
var max_health_upgrade : int= 5
