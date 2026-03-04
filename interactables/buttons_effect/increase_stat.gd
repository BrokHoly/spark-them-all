extends ButtonEffect
class_name IncreaseStat

@export var stat_name: String
@export var flat_bonus: float = 0.0
@export var mult_bonus: float = 0.0

func apply(player: Player):
	player.stats.add_flat(stat_name, flat_bonus)
	player.stats.add_multiplier(stat_name, mult_bonus)
