extends Node3D

var CAVE_LEVEL = 0
const SPAWN_MIN_RADIUS = 10.0
const SPAWN_MAX_RADIUS = 20.0

var total_enemies: int = 0
var enemies_alive: int = 0
var max_enemies_on_terrain : int = 7
var enemies_killed: int = 0
var enemies_spawned: int = 0

var spawning = false

@onready var nav_region: NavigationRegion3D = $NavigationRegion3D
@onready var terrain: Node3D = $NavigationRegion3D/Terrain
@onready var boular: PackedScene = preload("res://characters/enemies/boular/boular.tscn")

#Later, repalce that with a log calculation in calc_total_enemies().
const ENEMIES_BY_LEVELS = [20, 40, 80]

func _ready():
	CAVE_LEVEL = Game.cave_level
	await get_tree().create_timer(0.2).timeout
	calc_total_enemies()
	print("Level started with %d enemies" % total_enemies)
	print(nav_region.navigation_mesh)

func _on_enemy_killed():
	enemies_killed += 1
	enemies_alive -= 1   # 🔥 important
	
	print("Enemy killed: %d/%d" % [enemies_killed, total_enemies])
	
	if enemies_killed >= total_enemies:
		_complete_level()

func _complete_level():
	print("LEVEL COMPLETE!")
	await get_tree().create_timer(10.0).timeout
	SceneLoader.load_scene("uid://bkx628iow4cs5")

func calc_total_enemies():
	total_enemies = ENEMIES_BY_LEVELS[clamp(CAVE_LEVEL,1,3)-1]


func _get_spawn_position(player: Node3D) -> Vector3:
	var angle = randf() * TAU
	var distance = randf_range(SPAWN_MIN_RADIUS, SPAWN_MAX_RADIUS)
	var offset = Vector3(cos(angle) * distance, 0, sin(angle) * distance)
	return player.global_position + offset

func spawn_enemy():
	if enemies_spawned >= total_enemies:
		return
	if enemies_alive >= max_enemies_on_terrain:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var pos = find_valid_spawn(player)
	if pos == Vector3.ZERO:
		return
	var enemy = boular.instantiate()
	enemy.player = player
	enemy.global_position = pos
	add_child(enemy)
	enemy.killed.connect(_on_enemy_killed)
	enemies_spawned += 1
	enemies_alive += 1


func find_valid_spawn(player: Node3D) -> Vector3:
	var pos = _get_spawn_position(player)
	pos = _get_navmesh_point(pos)
	return pos

func _get_navmesh_point(pos: Vector3) -> Vector3:
	var nav_map = nav_region.get_navigation_map()
	var new_pos = NavigationServer3D.map_get_closest_point(nav_map, pos)
	return new_pos

func _on_spawn_timer_timeout() -> void:
	if enemies_spawned < total_enemies:
		spawn_enemy()
