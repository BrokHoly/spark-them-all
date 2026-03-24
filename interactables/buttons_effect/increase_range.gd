extends ButtonEffect
class_name IncreaseOverhaulRange


func apply(player:Player):
	if Game.lamp_range_upgrade > 0:
		Game.lamp_range_upgrade -= 1
		player.stats.add_multiplier("lamp_idle_range", 0.1)
		player.stats.add_multiplier("lamp_focus_range", 0.1)
