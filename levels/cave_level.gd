extends Node3D


var CAVE_LEVEL = 0

var total_enemies
var enemies_killed: int = 0

var spawning = false

#Later, repalce that with a log calculation in calc_total_enemies().
const ENEMIES_BY_LEVELS = [20, 40, 80]

func _ready():
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
	# Here you can:
	# 1. Notify GameManager
	# 2. Spawn the trampoline / portal
	# 3. Play animation or sound


func calc_total_enemies():
	total_enemies = ENEMIES_BY_LEVELS[clamp(CAVE_LEVEL,1,3)-1]
