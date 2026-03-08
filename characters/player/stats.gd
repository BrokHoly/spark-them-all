extends Resource
class_name Stats

var stats := {
	# Movement
	"speed": {
		"base": 5.0,
		"flat": 0.0,
		"mult": 1.0
	},
	"sprint_multiplier": {
		"base": 1.5,
		"flat": 0.0,
		"mult": 1.0
	},
	"walk_multiplier": {
		"base": 0.8,
		"flat": 0.0,
		"mult": 1.0
	},
	"jump_velocity": {
		"base": 4.5,
		"flat": 0.0,
		"mult": 1.0
	},
	
	# Health
	"max_health": {
		"base": 10.0,
		"flat": 0.0,
		"mult": 1.0
	},
	
	# Damage
	"lamp_idle_damage_cooldown": {
		"base": 0.5,
		"flat": 0.0,
		"mult": 1.0
	},
	"lamp_idle_damage_per_tick": {
		"base": 1.0,
		"flat": 0.0,
		"mult": 1.0
	},
	"lamp_focus_damage_cooldown": {
		"base": 0.5,
		"flat": 0.0,
		"mult": 1.0
	},
	"lamp_focus_damage_per_tick": {
		"base": 1.0,
		"flat": 0.0,
		"mult": 1.0
	},

	# Lamp / light
	"lamp_idle_angle": {
		"base": 40.0,
		"flat": 0.0,
		"mult": 1.0
	},
	"lamp_idle_range": {
		"base": 7.0,
		"flat": 0.0,
		"mult": 1.0
	},
	"lamp_focus_angle": {
		"base": 20.0,
		"flat": 0.0,
		"mult": 1.0
	},
	"lamp_focus_range": {
		"base": 15.0,
		"flat": 0.0,
		"mult": 1.0
	},
	
	# Misc
	"collectible_range": {
		"base": 1.1,
		"flat": 0.0,
		"mult": 1.0
	}
}

func get_stat(stat_name: String) -> float:
	if not stats.has(stat_name):
		return 0.0
	
	var s = stats[stat_name]
	return (s.base + s.flat) * s.mult


func add_flat(stat_name: String, value: float):
	if stats.has(stat_name):
		stats[stat_name].flat += value


func add_multiplier(stat_name: String, value: float):
	if stats.has(stat_name):
		stats[stat_name].mult += value


func set_base(stat_name: String, value: float):
	if stats.has(stat_name):
		stats[stat_name].base = value

func set_flat(stat_name: String, value: float):
	if stats.has(stat_name):
		stats[stat_name].flat = value

func set_mult(stat_name: String, value: float):
	if stats.has(stat_name):
		stats[stat_name].mult = value


func add_stat(stat_name: String, base: float = 0.0, flat: float = 0.0, mult: float = 1.0):
	if not stats.has(stat_name):
		stats[stat_name] = {
			"base": base,
			"flat": flat,
			"mult": mult
		}
