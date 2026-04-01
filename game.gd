extends Node


var player_stats: Stats
var player_health: float

var cave_level : int = 0

var lamp_range_upgrade : int= 10
var collect_range_upgrade : int= 5
var lamp_damage_upgrade : int= 5
var max_health_upgrade : int= 5


func reset_all():
	Engine.time_scale = 1.0

	player_stats = Stats.new()
	player_health = 5.0
	lamp_range_upgrade = 10
	collect_range_upgrade = 5
	lamp_damage_upgrade = 5
	max_health_upgrade = 5
