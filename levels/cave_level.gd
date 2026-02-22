extends Node3D

var CAVE_LEVEL = 0

var total_enemies: int = 0
var enemies_killed: int = 0

var spawning = false

@onready var nav_region: NavigationRegion3D = $NavigationRegion3D
@onready var terrain: Node3D = $Terrain

#Later, repalce that with a log calculation in calc_total_enemies().
const ENEMIES_BY_LEVELS = [20, 40, 80]

func _ready():
	terrain.generate_terrain()
	await get_tree().process_frame
	nav_region.bake_navigation_mesh()
	calc_total_enemies()
	#When spawning an ennemy, do not forget to add it the _on-enemy_killed signal.
	#ennemy.killed.connect(_on_enemy_killed)
	
	print("Level started with %d enemies" % total_enemies)

func _on_enemy_killed():
	enemies_killed += 1
	print("Enemy killed: %d/%d" % [enemies_killed, total_enemies])
	
	if enemies_killed >= total_enemies:
		_complete_level()

func _complete_level():
	print("LEVEL COMPLETE!")
	# Spawn the trampoline / portal

func calc_total_enemies():
	total_enemies = ENEMIES_BY_LEVELS[clamp(CAVE_LEVEL,1,3)-1]
