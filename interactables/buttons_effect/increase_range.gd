extends ButtonEffect
class_name IncreaseOverhaulRange

var upgrades_left = 5

func apply(player:Player):
	if(upgrades_left>0):
		player.stats.add_multiplier("lamp_idle_range", 0.5)
		player.stats.add_multiplier("lamp_focus_range", 0.5)
