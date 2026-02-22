extends Node3D

@export var total_enemies: int = 5
var enemies_killed: int = 0

func _ready():
	# Spawn or reference all Boulars
	var ennemies = get_tree().get_nodes_in_group("ennemy")
	total_enemies = ennemies.size()
	
	# Connect each Boular's killed signal
	for ennemy in ennemies:
		ennemy.killed.connect(_on_enemy_killed)
	
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
